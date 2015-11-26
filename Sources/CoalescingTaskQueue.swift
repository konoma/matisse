//
//  CoalescingTaskQueue.swift
//  Matisse
//
//  Created by Markus Gasser on 24.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/**
 * Task Queue that allows coalescing multiple tasks by reusing the result of a single
 * worker for multiple tasks. Consults with the Worker to decide what tasks can be
 * coalesced.
 */
internal class CoalescingTaskQueue<Worker: CoalescingTaskQueueWorker> {
    
    typealias CompletionHandler = (Worker.ResultType?, NSError?) -> Void
    
    private let worker: Worker
    private let syncQueue: DispatchQueue
    private var pendingTasks = [PendingTask<Worker.TaskType, Worker.ResultType>]()
    
    
    /**
     * Create a new task queue given a worker and a sync queue.
     *
     * The sync queue is used to synchronize access to the pending tasks
     * and must be a serial queue.
     */
    init(worker: Worker, syncQueue: DispatchQueue) {
        self.worker = worker
        self.syncQueue = syncQueue
    }
    
    /**
     * Submit a new task with the given completion handler.
     *
     * The task may be coalesced with an earlier task, thus reducing the load on the worker.
     *
     * The completion block will be called on the syncQueue.
     */
    func submit(task: Worker.TaskType, completion: CompletionHandler) {
        syncQueue.async {
            if let pendingTask = self.addPendingTask(task, withCompletion: completion) {
                self.executePendingTask(pendingTask)
            }
        }
    }
    
    private func executePendingTask(pendingTask: PendingTask<Worker.TaskType, Worker.ResultType>) {
        self.worker.handleTask(pendingTask.task) { result, error in
            self.syncQueue.async {
                if let index = self.pendingTasks.indexOf({ $0 === pendingTask }) {
                    self.pendingTasks.removeAtIndex(index)
                }
                pendingTask.notifyResult(result, error: error)
            }
        }
    }
    
    private func addPendingTask(task: Worker.TaskType, withCompletion completion: CompletionHandler) -> PendingTask<Worker.TaskType, Worker.ResultType>? {
        // try coalescing first
        for pendingTask in pendingTasks {
            if worker.canCoalesceTask(task, withTask: pendingTask.task) {
                pendingTask.addCompletionHandler(completion)
                return nil
            }
        }
        
        // couldn't coalesce, add a new task instead
        let pendingTask = PendingTask(task: task, completionHandler: completion)
        pendingTasks.append(pendingTask)
        return pendingTask
    }
}


/**
 * Protocol for classes that execute tasks in a CoalescingTaskQueue.
 * Specify wether tasks can be coalesced or not.
 */
internal protocol CoalescingTaskQueueWorker {
    
    typealias TaskType
    typealias ResultType
    
    /**
     * Called when the worker needs to execute the given task.
     */
    func handleTask(task: TaskType, completion: (ResultType?, NSError?) -> Void)
    
    /**
     * Called to let the handler decide wether two tasks can be executed as one.
     */
    func canCoalesceTask(newTask: TaskType, withTask currentTask: TaskType) -> Bool
}


/**
 * Represents a task currently being executed. Allows adding completion handlers
 * to support task coalescing.
 */
internal class PendingTask<TaskType, ResultType> {
    
    private let task: TaskType
    private var completionHandlers: [(ResultType?, NSError?) -> Void]
    
    init(task: TaskType, completionHandler: (ResultType?, NSError?) -> Void) {
        self.task = task
        self.completionHandlers = [completionHandler]
    }
    
    /**
     * Add a completion handler to this pending task.
     *
     * Used to coalesce two tasks.
     */
    func addCompletionHandler(completionHandler: (ResultType?, NSError?) -> Void) {
        completionHandlers.append(completionHandler)
    }
    
    /**
     * Notify all registered completion handlers of a result.
     *
     * Must be called on the sync queue.
     */
    func notifyResult(result: ResultType?, error: NSError?) {
        for handler in completionHandlers {
            handler(result, error)
        }
    }
}
