//
//  DispatchQueue.swift
//  Matisse
//
//  Created by Markus Gasser on 22.11.15.
//  Copyright © 2015 konoma GmbH. All rights reserved.
//

import Foundation


internal class DispatchQueue {
    
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
    
    static let main = DispatchQueue(dispatchQueue: dispatch_get_main_queue())
    
    private let dispatchQueue: dispatch_queue_t
    
    init(dispatchQueue: dispatch_queue_t) {
        self.dispatchQueue = dispatchQueue
    }
    
    convenience init(label: String, type: ExecutionType) {
        self.init(dispatchQueue: dispatch_queue_create(label, type.dispatchAttribute()))
    }
    
    func sync(block: dispatch_block_t) {
        dispatch_sync(dispatchQueue, block)
    }
    
    func async(block: dispatch_block_t) {
        dispatch_async(dispatchQueue, block)
    }
}