//
//  Cache+all.swift
//  CacheKit
//
//  Created by Hans Rietmann on 02/12/2021.
//

import Foundation






extension AsyncCache {
    
    
    public var all: AsyncThrowingStream<Value, Error> {
        get async throws {
            let entries = keyTracker.keys.compactMap { key -> Entry<Value>? in
                guard let entry = wrapped.object(forKey: WrappedKey(key)) else { return nil }
                guard Date() < entry.expirationDate else {
                    removeValue(at: key)
                    return nil
                }
                return entry
            }
            return .init { continuation in
                Task {
                    do {
                        for entry in entries {
                            let value = try await entry.state.value
                            continuation.yield(value)
                        }
                        continuation.finish(throwing: nil)
                    } catch {
                        continuation.finish(throwing: error)
                    }
                }
            }
        }
    }
    
    
}



extension AsyncThrowingStream {
    
    public var values: [Element] {
        get async throws {
            var elements = [Element]()
            for try await element in self {
                elements.append(element)
            }
            return elements
        }
    }
    
}
