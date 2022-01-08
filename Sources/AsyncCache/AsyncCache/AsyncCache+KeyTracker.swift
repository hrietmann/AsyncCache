//
//  Cache+KeyTracker.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation





extension AsyncCache {
    
    
    final class KeyTracker: NSObject, NSCacheDelegate {
        var keys = Set<Key>()
        
        func cache(_ cache: NSCache<AnyObject, AnyObject>, willEvictObject object: Any) {
            guard let entry = object as? Entry<Value> else {
                return
            }
            
            keys.remove(entry.key)
        }
    }
    
    
}
