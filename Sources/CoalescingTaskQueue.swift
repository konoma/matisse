//
//  CoalescingTaskQueue.swift
//  Matisse
//
//  Created by Markus Gasser on 24.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// Task Queue that allows coalescing multiple tasks by reusing the result of a single
/// worker for multiple tasks.
///
/// Consults with the Worker to decide what tasks can be coalesced.
///
internal class CoalescingTaskQueue<Worker: CoalescingTaskQueueWorker> {

    typealias CompletionHandler = (Worker.ResultType?, NSError?) -> Void
    typealias Task = PendingTask<Worker.TaskType, Worker.ResultType>

    private let worker: Worker
    private let syncQueue: DispatchQueue
    private var pendingTasks = [Task]()


    /// Create a new task queue given a worker and a sync queue.
    ///
    /// The sync queue is used to synchronize access to the pending tasks and must be a serial queue.
    ///
    /// - Parameters:
    ///   - worker:    The worker that handles the tasks.
    ///   - syncQueue: The dispatch queue used to synchronize access to the task queue.
    ///
    init(worker: Worker, syncQueue: DispatchQueue) {
        self.worker = worker
        self.syncQueue = syncQueue
    }

    /// Submit a new task with the given completion handler.
    ///
    /// The task may be coalesced with an earlier task, thus reducing the load on the worker.
    ///
    /// If the task was not coalesced but effectively executed, then the `requestCompletion` block
    /// is called. Otherwise this block is never called.
    ///
    /// The `taskCompletion` block is always called when the task gets a result, regardless of
    /// wether it was actually executed or coalesced.
    ///
    /// - Note:
    ///   The completion block will be called on the syncQueue.
    ///
    /// - Parameters:
    ///   - task:              The task to submit to the queue.
    ///   - requestCompletion: The completion block called if this task was actually executed.
    ///   - taskCompletion:    The completion block called when a result for this task was obtained.
    ///
    func submit(task: Worker.TaskType, requestCompletion: /*@escaping*/ CompletionHandler?, taskCompletion: @escaping CompletionHandler) {
        syncQueue.async {
            if let pendingTask = self.addPendingTask(forTask: task, withCompletion: taskCompletion) {
                self.execute(pendingTask: pendingTask, requestCompletion: requestCompletion)
            }
        }
    }

    private func execute(pendingTask: Task, requestCompletion: CompletionHandler?) {
        self.worker.handle(task: pendingTask.task) { result, error in
            self.syncQueue.async {
                if let index = self.pendingTasks.index(where: { $0 === pendingTask }) {
                    self.pendingTasks.remove(at: index)
                }
                requestCompletion?(result, error)
                pendingTask.notify(result: result, error: error)
            }
        }
    }

    private func addPendingTask(forTask task: Worker.TaskType, withCompletion completion: @escaping CompletionHandler) -> Task? {
        // try coalescing first
        for pendingTask in pendingTasks {
            if worker.canCoalesce(task: task, withTask: pendingTask.task) {
                pendingTask.add(completionHandler: completion)
                return nil
            }
        }

        // couldn't coalesce, add a new task instead
        let pendingTask = PendingTask(task: task, completionHandler: completion)
        pendingTasks.append(pendingTask)
        return pendingTask
    }
}



/// Protocol for classes that execute tasks in a CoalescingTaskQueue.
///
/// Also decides which tasks can be coalesced and which not.
///
internal protocol CoalescingTaskQueueWorker {

    associatedtype TaskType
    associatedtype ResultType


    /// Execute the given task.
    ///
    /// Called by the task queue when this worker needs to execute the given task.
    ///
    /// - Parameters:
    ///   - task:       The executed task.
    ///   - completion: The completion handler to call when the task finishes.
    ///
    func handle(task: TaskType, completion: @escaping (ResultType?, NSError?) -> Void)

    /**
     * Called to let the handler decide wether two tasks can be executed as one.
     */

    /// Decides wether two tasks can be coalesced.
    ///
    /// - Parameters:
    ///   - newTask:     The new task that should be coalesced.
    ///   - currentTask: An existing task to coalesce the new task with.
    ///
    /// - Returns:
    ///   `true` if the two tasks can be coalesced, `false` otherwise.
    ///
    func canCoalesce(task newTask: TaskType, withTask currentTask: TaskType) -> Bool
}


/// Represents a task currently being executed. Allows adding completion handlers
/// to support task coalescing.
///
internal class PendingTask<TaskType, ResultType> {

    /// The task that caused this pending task
    let task: TaskType

    private var completionHandlers: [(ResultType?, NSError?) -> Void]

    /// Create a new pending task with the given task and completion handler.
    ///
    /// - Parameters:
    ///   - task:              The task that caused this pending task.
    ///   - completionHandler: The initial completion handler for this task.
    ///
    init(task: TaskType, completionHandler: @escaping (ResultType?, NSError?) -> Void) {
        self.task = task
        self.completionHandlers = [completionHandler]
    }

    /// Add a completion handler to this pending task.
    ///
    /// This is called when the task queue coalesces a task, so that the coalesced
    /// task still gets notified of the result.
    ///
    /// - Parameters:
    ///   - completionHandler: The completion handler to call when this pending task is resolved.
    ///
    func add(completionHandler: @escaping (ResultType?, NSError?) -> Void) {
        completionHandlers.append(completionHandler)
    }

    /// Notify all registered completion handlers of a result.
    ///
    /// - Note:
    ///   Must be called on the sync queue.
    ///
    /// - Parameters:
    ///   - result: The result of the task if successful, `nil` otherwise.
    ///   - error:  The error result of the task if failed, `nil` otherwise.
    ///
    func notify(result: ResultType?, error: NSError?) {
        for handler in completionHandlers {
            handler(result, error)
        }
    }
}
