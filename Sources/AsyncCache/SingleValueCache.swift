//
//  SingleValueCache.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation




public final class SingleValueCache<Value> {
    
    let id: UUID
    var cache: AsyncCache<UUID, Value>
    
    init(id: UUID, cache: AsyncCache<UUID, Value>) {
        self.id = id
        self.cache = cache
    }
    public convenience init(entryLifetime: TimeInterval = 12 * 60 * 60) {
        self.init(id: UUID(), cache: .init(entryLifetime: entryLifetime, maximumEntryCount: 1))
    }
    
    public func inserting(_ task: Task<Value, Error>) async throws -> Value
    { try await cache.inserting(task, at: id) }
    
    public func insert(_ value: Value)
    { cache.insert(value, at: id) }
    
    public var value: Value?
    { get async throws { try await cache.value(id) } }
    
    public func removeValue()
    { cache.removeValue(at: id) }
    
}


extension SingleValueCache where Value: Codable {
    
    public convenience init(fileName name: String, lifetime: TimeInterval = 12 * 60 * 60) throws {
        let cache = try AsyncCache<UUID, Value>.init(fileName: name, lifetime: lifetime, maxCount: 1)
        let id = cache.keyTracker.keys.first ?? UUID()
        self.init(id: id, cache: cache)
    }
    
    public func saveToDisk() async throws
    { try await cache.saveToDisk() }
    
    public func clearFromDisk() throws
    { try cache.clearFromDisk() }
    
}
