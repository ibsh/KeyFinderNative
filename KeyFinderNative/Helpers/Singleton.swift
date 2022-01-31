//
//  Singleton.swift
//  KeyFinder
//
//  Created by Ibrahim Sha'ath on 29/12/2021.
//  Copyright © 2021 Ibrahim Sha'ath. All rights reserved.
//

import Foundation

final class Singleton<T> {

    private let factory: () -> T
    private let lock = NSRecursiveLock()
    private var resource: T?

    init(factory: @escaping () -> T) {
        self.factory = factory
    }

    func get() -> T {
        lock.lock()
        defer { lock.unlock() }
        if let resource = resource {
            return resource
        }
        let resource = factory()
        self.resource = resource
        return resource
    }
}
