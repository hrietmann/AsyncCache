//
//  Cache+Entry.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation




extension AsyncCache {
    
    
    final class Entry<Value> {
        
        enum State<Value> {
            case inProgress(Task<Value, Error>)
            case ready(Value)
            var isReady: Bool {
                switch self {
                case .ready: return true
                default: return false
                }
            }
            var value: Value {
                get async throws {
                    switch self {
                    case .inProgress(let task): return try await task.value
                    case .ready(let value): return value
                    }
                }
            }
        }
        private var task: Task<Value, Error>?
        private var value: Value?
        var state: State<Value> {
            get {
                if let task = task { return .inProgress(task) }
                return .ready(value!)
            }
            set {
                if !state.isReady, newValue.isReady {
                    let diff = Date().timeIntervalSince(expirationDate)
                    expirationDate = expirationDate.addingTimeInterval(abs(diff))
                }
                switch newValue {
                case .inProgress(let task):
                    self.task = task
                    self.value = nil
                case .ready(let value):
                    self.task = nil
                    self.value = value
                }
            }
        }
        private(set) var expirationDate: Date
        let key: Key
        
        init(key: Key, state: State<Value>, expiration: Date) {
            self.key = key
            switch state {
            case .inProgress(let task):
                self.task = task
                self.value = nil
            case .ready(let value):
                self.task = nil
                self.value = value
            }
            self.expirationDate = expiration
        }
    }
    
    
}



extension AsyncCache.Entry where Key: Codable, Value: Codable {
    
    
    struct Loaded: Codable {
        let key: Key
        let value: Value
        let expiration: Date
    }
    
    var loaded: Loaded {
        get async throws {
            let value = try await state.value
            return .init(key: key, value: value, expiration: expirationDate)
        }
    }
    
    convenience init(loadedEntry: Loaded) {
        self.init(key: loadedEntry.key, state: .ready(loadedEntry.value), expiration: loadedEntry.expiration)
    }
    
    
}
