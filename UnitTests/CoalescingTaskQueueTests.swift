//
//  CoalescingTaskQueueTests.swift
//  Matisse
//
//  Created by Markus Gasser on 26.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import XCTest
import Nimble

@testable import Matisse


class CoalescingTaskQueueTests: XCTestCase {

    class NonCoalescingWorker: CoalescingTaskQueueWorker {
        
        var handledTaskCount = 0
        
        func handleTask(task: String, completion: (Result<String>) -> Void) {
            handledTaskCount += 1
            completion(Result.success(task))
        }
        
        func canCoalesceTask(newTask: String, withTask currentTask: String) -> Bool {
            return false
        }
    }
    
    class CoalescingWorker: CoalescingTaskQueueWorker {
        
        var handledTaskCount = 0
        
        func handleTask(task: String, completion: (Result<String>) -> Void) {
            handledTaskCount += 1
            completion(Result.success(task))
        }
        
        func canCoalesceTask(newTask: String, withTask currentTask: String) -> Bool {
            return newTask == currentTask
        }
    }
    
    
    func test_submitting_will_handle_the_task_using_the_worker() {
        let queue = CoalescingTaskQueue(worker: NonCoalescingWorker(), syncQueue: DispatchQueue.main)
        
        var resultValue: String?
        queue.submit("Test") { result in
            resultValue = result.value
        }
        
        expect(resultValue).toEventually(equal("Test"))
    }
    
    func test_submitting_multiple_tasks_will_coalesce_if_allowed() {
        let worker = CoalescingWorker()
        let queue = CoalescingTaskQueue(worker: worker, syncQueue: DispatchQueue.main)
        
        var resultCount = 0
        queue.submit("Test") { result in expect(result.value).to(equal("Test")); resultCount += 1 }
        queue.submit("Test") { result in expect(result.value).to(equal("Test")); resultCount += 1 }
        
        // we expect two completion calls to be made, but only one task should be executed
        expect(resultCount).toEventually(equal(2))
        expect(worker.handledTaskCount).toNotEventually(beGreaterThan(1))
    }
    
    func test_submitting_multiple_tasks_will_not_coalesce_if_disallowed() {
        let worker = NonCoalescingWorker()
        let queue = CoalescingTaskQueue(worker: worker, syncQueue: DispatchQueue.main)
        
        var resultCount = 0
        queue.submit("Test") { result in expect(result.value).to(equal("Test")); resultCount += 1 }
        queue.submit("Test") { result in expect(result.value).to(equal("Test")); resultCount += 1 }
        
        // we expect two completion calls to be made, and also two tasks to be executed
        expect(resultCount).toEventually(equal(2))
        expect(worker.handledTaskCount).toEventually(equal(2))
    }
}
