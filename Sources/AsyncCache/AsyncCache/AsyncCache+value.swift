//
//  Cache+value.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation




extension AsyncCache {
    
    
    public func value(_ key: Key) async throws -> Value? {
        guard let entry = self[key] else { return nil }
        switch entry.state {
        case .inProgress(let task):
            let value = try await task.value
            self[key]?.state = .ready(value)
            return value
        case .ready(let value):
            guard Date() < entry.expirationDate else {
                self[key] = nil
                return nil
            }
            return value
        }
    }
    
    
}
