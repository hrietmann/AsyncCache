//
//  Cache.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation
//import AppKit



// https://www.swiftbysundell.com/articles/caching-in-swift/
public final class AsyncCache<Key: Hashable, Value> {
    
    
    var wrapped = NSCache<WrappedKey, Entry<Value>>()
    subscript(_ key: Key) -> Entry<Value>? {
        get { wrapped.object(forKey: .init(key)) }
        set {
            guard let value = newValue
            else { wrapped.removeObject(forKey: .init(key)) ; return }
            wrapped.setObject(value, forKey: .init(key))
        }
    }
    
    let entryLifetime: TimeInterval
    var expiration: Date { Date().addingTimeInterval(entryLifetime) }
    let keyTracker = KeyTracker()
    let fileName: String?
    
    
    init(fileName: String?, entryLifetime: TimeInterval, maximumEntryCount: Int) {
        self.fileName = fileName
        self.entryLifetime = entryLifetime
        wrapped.countLimit = maximumEntryCount
        wrapped.delegate = keyTracker
    }
    deinit {
        wrapped.removeAllObjects()
    }
    
    public convenience init(entryLifetime: TimeInterval = 12 * 60 * 60, maximumEntryCount: Int = 50) {
        self.init(fileName: nil, entryLifetime: entryLifetime, maximumEntryCount: maximumEntryCount)
    }
    
    
}
