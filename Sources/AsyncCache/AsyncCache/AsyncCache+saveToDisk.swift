//
//  Cache+saveToDisk.swift
//  CacheKit
//
//  Created by Hans Rietmann on 01/12/2021.
//

import Foundation
import CodableKit





extension AsyncCache where Key: Codable, Value: Codable {
    
    
    public convenience init(fileName name: String, lifetime: TimeInterval = 12 * 60 * 60, maxCount: Int = 50) throws {
        let manager = FileManager.default
        let folderURLs = manager.urls(for: .cachesDirectory, in: .userDomainMask)
        let fileURL = folderURLs[0]
            .appendingPathComponent(name)
            .appendingPathExtension("cache")
        
        guard let data = manager.contents(atPath: fileURL.path) else {
            self.init(fileName: name, entryLifetime: lifetime, maximumEntryCount: maxCount)
            return
        }
        let buffer = try Buffer.from(data: data)
        self.init(fileName: name, entryLifetime: buffer.entryLifetime, maximumEntryCount: buffer.maximumEntryCount)
        buffer.loadedEntries.forEach { loadedEntry in
            let entry = Entry<Value>.init(loadedEntry: loadedEntry)
            wrapped.setObject(entry, forKey: WrappedKey(entry.key))
            keyTracker.keys.insert(entry.key)
        }
    }
    
    
    struct Buffer: Codable {
        let entryLifetime: TimeInterval
        let maximumEntryCount: Int
        let loadedEntries: [Entry<Value>.Loaded]
    }
    
    var fileURL: URL {
        get throws {
            guard let fileName = fileName else {
                let message = "'fileName' not provided! Please use this the .init(fileName:lifetime:maxCount:) initialiser for cache to be stored on disk."
                throw CacheError(message: message)
            }
            let folderURLs = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
            return folderURLs[0]
                .appendingPathComponent(fileName)
                .appendingPathExtension("cache")
        }
    }
    
    public func saveToDisk() async throws {
        let entries = keyTracker.keys.compactMap { key -> Entry<Value>? in
            guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }
            guard Date() < entry.expirationDate else {
                removeValue(at: key)
                return nil
            }
            return entry
        }
        let loadedEntries = try await withThrowingTaskGroup(of: Entry<Value>.Loaded.self) { tasks -> [Entry<Value>.Loaded] in
            for entry in entries { tasks.addTask { try await entry.loaded } }
            var loadedEntries = [Entry<Value>.Loaded]()
            loadedEntries.reserveCapacity(entries.count)
            for try await loadedEntry in tasks { loadedEntries.append(loadedEntry) }
            return loadedEntries
        }
        let buffer = Buffer(entryLifetime: entryLifetime, maximumEntryCount: wrapped.countLimit, loadedEntries: loadedEntries)
        let data = try buffer.data
        try data.write(to: try fileURL)
    }
    
    
    public func clearFromDisk() throws {
        try FileManager.default.removeItem(at: try fileURL)
    }
    
    
}
