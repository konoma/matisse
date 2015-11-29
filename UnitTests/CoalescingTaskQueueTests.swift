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

    func test_submitting_will_handle_the_task_using_the_worker() {
        let queue = CoalescingTaskQueue(worker: InspectableTaskQueueWorker(coalesce: true), syncQueue: DispatchQueue.main)
        
        var resultValue: String?
        queue.submit("Test", requestCompletion: nil) { result, error in
            resultValue = result
        }
        
        expect(resultValue).toEventually(equal("Test"))
    }
    
    func test_submitting_multiple_tasks_will_coalesce_if_allowed() {
        let worker = InspectableTaskQueueWorker(coalesce: true)
        let queue = CoalescingTaskQueue(worker: worker, syncQueue: DispatchQueue.main)
        
        var resultCount = 0
        queue.submit("Test", requestCompletion: nil) { result, _ in expect(result).to(equal("Test")); resultCount += 1 }
        queue.submit("Test", requestCompletion: nil) { result, _ in expect(result).to(equal("Test")); resultCount += 1 }
        
        // we expect two completion calls to be made, but only one task should be executed
        expect(resultCount).toEventually(equal(2))
        expect(worker.handledTaskCount).toNotEventually(beGreaterThan(1))
    }
    
    func test_submitting_multiple_tasks_will_not_coalesce_if_disallowed() {
        let worker = InspectableTaskQueueWorker(coalesce: false)
        let queue = CoalescingTaskQueue(worker: worker, syncQueue: DispatchQueue.main)
        
        var resultCount = 0
        queue.submit("Test", requestCompletion: nil) { result, _ in expect(result).to(equal("Test")); resultCount += 1 }
        queue.submit("Test", requestCompletion: nil) { result, _ in expect(result).to(equal("Test")); resultCount += 1 }
        
        // we expect two completion calls to be made, and also two tasks to be executed
        expect(resultCount).toEventually(equal(2))
        expect(worker.handledTaskCount).toEventually(equal(2))
    }
    
    func test_submitting_coalesced_tasks_will_call_request_completion_once() {
        let worker = InspectableTaskQueueWorker(coalesce: true)
        let queue = CoalescingTaskQueue(worker: worker, syncQueue: DispatchQueue.main)
        
        var resultCount = 0
        let requestCompletion = { (result: String?, _: NSError?) in expect(result).to(equal("Test")); resultCount += 1 }
        
        queue.submit("Test", requestCompletion: requestCompletion) { _, _ in }
        queue.submit("Test", requestCompletion: requestCompletion) { _, _ in }
        
        // we expect two completion calls to be made, and also two tasks to be executed
        expect(resultCount).toEventually(equal(1))
    }
    
    func test_submitting_non_coalesced_tasks_will_call_request_completion_for_each() {
        let worker = InspectableTaskQueueWorker(coalesce: false)
        let queue = CoalescingTaskQueue(worker: worker, syncQueue: DispatchQueue.main)
        
        var resultCount = 0
        let requestCompletion = { (result: String?, _: NSError?) in expect(result).to(equal("Test")); resultCount += 1 }
        
        queue.submit("Test", requestCompletion: requestCompletion) { _, _ in }
        queue.submit("Test", requestCompletion: requestCompletion) { _, _ in }
        
        // we expect two completion calls to be made, and also two tasks to be executed
        expect(resultCount).toEventually(equal(2))
    }
}


private class InspectableTaskQueueWorker: CoalescingTaskQueueWorker {
    
    private let coalesce: Bool
    
    init(coalesce: Bool) {
        self.coalesce = coalesce
    }
    
    var handledTaskCount = 0
    
    func handleTask(task: String, completion: (String?, NSError?) -> Void) {
        handledTaskCount += 1
        completion(task, nil)
    }
    
    func canCoalesceTask(newTask: String, withTask currentTask: String) -> Bool {
        return coalesce && newTask == currentTask
    }
}
