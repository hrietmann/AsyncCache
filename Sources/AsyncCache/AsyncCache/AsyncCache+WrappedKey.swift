//
//  Cache+WrappedKey.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation




extension AsyncCache {
    
    
    final class WrappedKey: NSObject {
        let key: Key
        
        init(_ key: Key) { self.key = key }
        
        override var hash: Int { return key.hashValue }
        
        override func isEqual(_ object: Any?) -> Bool {
            guard let value = object as? WrappedKey else {
                return false
            }
            
            return value.key == key
        }
    }
    
    
}
