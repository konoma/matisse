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
    
    private let worker: Worker
    private let syncQueue: DispatchQueue
    private var pendingTasks = [CoalescedTaskHolder<Worker.TaskType, Worker.ResultType>]()
    
    
    init(worker: Worker, syncQueue: DispatchQueue) {
        self.worker = worker
        self.syncQueue = syncQueue
    }
    
    func submit(task: Worker.TaskType, completion: (Result<Worker.ResultType>) -> Void) {
        syncQueue.async {
            if self.addPendingTask(task, withCompletion: completion) {
                self.worker.handleTask(task, completionQueue:self.syncQueue, completion: completion)
            }
        }
    }
    
    // adds a pending task, will return true if the task needs to be passed to the worker (i.e. can't be coalesced)
    private func addPendingTask(task: Worker.TaskType, withCompletion completion: (Result<Worker.ResultType>) -> Void) -> Bool {
        // try coalescing first
        for pendingTask in pendingTasks {
            if worker.canCoalesceTask(task, withTask: pendingTask.task) {
                pendingTask.addCompletionHandler(completion)
                return false
            }
        }
        
        // couldn't coalesce, add a new task instead
        pendingTasks.append(CoalescedTaskHolder(task: task, completionHandler: completion))
        return true
    }
}


internal protocol CoalescingTaskQueueWorker {
    
    typealias TaskType
    typealias ResultType
    
    func handleTask(task: TaskType, completionQueue: DispatchQueue, completion: (Result<ResultType>) -> Void)
    
    func canCoalesceTask(newTask: TaskType, withTask currentTask: TaskType) -> Bool
}


internal class CoalescedTaskHolder<TaskType, ResultType> {
    
    private let task: TaskType
    private var completionHandlers: [(Result<ResultType>) -> Void]
    
    init(task: TaskType, completionHandler: (Result<ResultType>) -> Void) {
        self.task = task
        self.completionHandlers = [completionHandler]
    }
    
    func addCompletionHandler(completionHandler: (Result<ResultType>) -> Void) {
        completionHandlers.append(completionHandler)
    }
}