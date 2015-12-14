//
//  DispatchQueue.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


/// Wrapper around `dispatch_queue_t` to provide more convenient access.
///
internal class DispatchQueue {

    /// The execution type of the dispatch queue.
    ///
    /// Either serial or concurrent.
    ///
    enum ExecutionType {
        case Serial
        case Concurrent

        func dispatchAttribute() -> dispatch_queue_attr_t? {
            switch self {
            case .Serial:     return DISPATCH_QUEUE_SERIAL
            case .Concurrent: return DISPATCH_QUEUE_CONCURRENT
            }
        }
    }


    private let dispatchQueue: dispatch_queue_t


    // MARK: - Globals

    /// The main dispatch queue (`dispatch_get_main_queue()` equivalent).
    ///
    static let main = DispatchQueue(dispatchQueue: dispatch_get_main_queue())


    // MARK: - Initialization

    /// Create a new `DispatchQueue` with the given label and execution type.
    ///
    /// - Parameters:
    ///   - label: The label for the new dispatch queue.
    ///   - type:  The execution type (serial or concurrent) for the new dispatch queue.
    ///
    convenience init(label: String, type: ExecutionType) {
        self.init(dispatchQueue: dispatch_queue_create(label, type.dispatchAttribute()))
    }

    /// Create a new `DispatchQueue` with the given `dispatch_queue_t`.
    ///
    /// - Parameters:
    ///   - dispatchQueue: The `dispatch_queue_t` to wrap.
    ///
    init(dispatchQueue: dispatch_queue_t) {
        self.dispatchQueue = dispatchQueue
    }


    // MARK: - Submitting Blocks

    /// Submit a queue to this queue synchronously.
    ///
    /// - Parameters:
    ///   - block: The block to submit.
    ///
    func sync(block: dispatch_block_t) {
        dispatch_sync(dispatchQueue, block)
    }

    /// Submit a queue to this queue asynchronously.
    ///
    /// - Parameters:
    ///   - block: The block to submit.
    ///
    func async(block: dispatch_block_t) {
        dispatch_async(dispatchQueue, block)
    }
}
