//
//  SharedManager.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

public final class SharedManager {
    private var registry = Registry()
    private let mutex = NSLock()
    internal func internalBorrow<R>(_ props: [AnyObject], accessBlock: () -> R) -> R {
        let active = activateBorrowingFor(props)
        defer {
            deactivateBorrowing(active)
            active.revoke()
        }
        return accessBlock()
    }
    private func activateBorrowingFor(_ props: [AnyObject]) -> Borrowing {
        while true {
            mutex.lock()
            let preservedRegistry = registry
            mutex.unlock()

            let new = Borrowing(props)
            if let blockingBorrowing = preservedRegistry.searchForConflictingBorrowingWith(new) {
                blockingBorrowing.wait()
            }

            mutex.lock()
            defer { mutex.unlock() }
            if registry !== preservedRegistry {
                continue
            }
            registry = registry.copyWithAdded(new)
            return new // bail out
        }
    }
    private func deactivateBorrowing(_ borrowing: Borrowing) {
        mutex.lock()
        defer { mutex.unlock() }
        registry = registry.copyWithRemoved(borrowing)
    }
    public init() {}
}
