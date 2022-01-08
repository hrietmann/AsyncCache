//
//  Cache+insert.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation





extension AsyncCache {
    
    
    public func inserting(_ task: Task<Value, Error>, at key: Key) async throws -> Value {
        if let entry = self[key] {
            switch entry.state {
            case .inProgress(let task): task.cancel()
            case .ready: break
            }
        }
        self[key] = Entry(key: key, state: .inProgress(task), expiration: expiration)
        keyTracker.keys.insert(key)
        let value = try await task.value
        self[key]?.state = .ready(value)
        return value
    }
    
    public func insert(_ value: Value, at key: Key) {
        if let entry = self[key] {
            switch entry.state {
            case .inProgress(let task): task.cancel()
            case .ready: break
            }
            self[key]?.state = .ready(value)
        } else {
            self[key] = Entry(key: key, state: .ready(value), expiration: expiration)
        }
        keyTracker.keys.insert(key)
    }
    
    
}
