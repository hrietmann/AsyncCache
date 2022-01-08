//
//  Cache+removeValue.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation




extension AsyncCache {
    
    
    public func removeValue(at key: Key) {
        if let entry = self[key] {
            switch entry.state {
            case .inProgress(let task): task.cancel()
            case .ready: break
            }
        }
        self[key] = nil
    }
    
    
}
