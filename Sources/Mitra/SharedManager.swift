//
//  SharedManager.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mutexes

public final class SharedManager {
    // MARK: - State

    private var registry = Registry()
    private let mutex = PthreadMutex()

    // MARK: - Initialization

    public init() {}

    // MARK: - UI

    @usableFromInline @discardableResult
    func internalBorrow<R>(_ props: ContiguousArray<Borrowable>, accessBlock: () -> R) -> R {
        let active = activateBorrowingFor(props)
        defer {
            deactivateBorrowing(active)
            active.revoke()
        }
        return accessBlock()
    }

    @usableFromInline @discardableResult
    func internalBorrow<R>(_ props: ContiguousArray<Borrowable>, accessBlock: () throws -> R) throws -> R {
        let active = activateBorrowingFor(props)
        defer {
            deactivateBorrowing(active)
            active.revoke()
        }
        return try accessBlock()
    }

    // MARK: - Helpers

    @inline(__always)
    private func activateBorrowingFor(_ props: ContiguousArray<Borrowable>) -> Borrowing {
        while true {
            mutex.lock()
            let preservedRegistry = registry
            mutex.unlock()

            let newBorrowing = Borrowing(props)
            if let blockingBorrowing = preservedRegistry.searchForConflictingBorrowingWith(newBorrowing) {
                blockingBorrowing.wait()
                continue // a new borrow state has been activated, so start over
            }

            mutex.lock()
            defer { mutex.unlock() }
            if registry !== preservedRegistry {
                continue
            }
            registry = registry.copyWithAdded(newBorrowing)
            return newBorrowing // bail out
        }
    }

    @inline(__always)
    private func deactivateBorrowing(_ borrowing: Borrowing) {
        mutex.lock()
        defer { mutex.unlock() }
        registry = registry.copyWithRemoved(borrowing)
    }
}
