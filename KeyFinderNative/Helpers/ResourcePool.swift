//
//  ResourcePool.swift
//  KeyFinderNative
//
//  Created by Ibrahim Sha'ath on 29/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class ResourcePool<T> {

    private let factory: () -> T
    private let lock = NSRecursiveLock()
    private var pool = [PooledResource<T>]()

    init(factory: @escaping () -> T) {
        self.factory = factory
    }

    func get() -> PooledResourceWrapper<T> {
        lock.lock()
        defer { lock.unlock() }
        if let wrappedResource = pool.first(where: { $0.wrapper == nil }) {
            return PooledResourceWrapper(wrapped: wrappedResource)
        }
        let wrappedResource = PooledResource(resource: factory())
        pool.append(wrappedResource)
        return PooledResourceWrapper(wrapped: wrappedResource)
    }
}

final class PooledResource<T> {

    weak var wrapper: PooledResourceWrapper<T>?
    let resource: T

    init(resource: T) {
        self.resource = resource
    }
}

final class PooledResourceWrapper<T> {

    let wrapped: PooledResource<T>

    init(wrapped: PooledResource<T>) {
        self.wrapped = wrapped
        wrapped.wrapper = self
    }
}
