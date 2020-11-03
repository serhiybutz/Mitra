//
//  SharedManager.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Atomics
import Darwin

public final class SharedManager {
    // MARK: - State

    private var sharedRegistry = ManagedAtomic(Registry()) // for inter-thread use (requires synchronization)

    // MARK: - Initialization

    public init() {}

    // MARK: - UI

    @usableFromInline @discardableResult
    func internalBorrow<R>(_ props: ContiguousArray<Borrowable>, accessBlock: () -> R) -> R {
        let tid = getThreadId()
        let active = activateBorrowingFor(props, tid)
        defer {
            deactivateBorrowing(active)
            active.revoke()
        }
        return accessBlock()
    }

    @usableFromInline @discardableResult
    func internalBorrow<R>(_ props: ContiguousArray<Borrowable>, accessBlock: () throws -> R) throws -> R {
        let tid = getThreadId()
        let active = activateBorrowingFor(props, tid)
        defer {
            deactivateBorrowing(active)
            active.revoke()
        }
        return try accessBlock()
    }

    // MARK: - Helpers

    @inline(__always)
    private func activateBorrowingFor(_ props: ContiguousArray<Borrowable>, _ tid: UInt64) -> Borrowing {
        while true {
            let registry = sharedRegistry.load(ordering: .acquiring)

            let newBorrowing = Borrowing(props, tid)

            if let blockingBorrowing = registry.searchForConflictingBorrowingWith(newBorrowing) {
                blockingBorrowing.wait()
                continue
            }

            let newRegistry = registry.copyWithAdded(newBorrowing)

            if sharedRegistry.compareExchange(expected: registry, desired: newRegistry, successOrdering: .releasing, failureOrdering: .relaxed).exchanged {
                return newBorrowing // bail out
            }
        }
    }

    @inline(__always)
    private func deactivateBorrowing(_ borrowing: Borrowing) {
        while true {
            let registry = sharedRegistry.load(ordering: .acquiring)

            let newRegistry = registry.copyWithRemoved(borrowing)

            if sharedRegistry.compareExchange(expected: registry, desired: newRegistry, successOrdering: .releasing, failureOrdering: .relaxed).exchanged {
                return // bail out
            }
        }
    }

    // takes about 5-7ns
    @inline(__always)
    private func getThreadId() -> UInt64 {
        var tid: UInt64 = 0
        pthread_threadid_np(nil, &tid)
        return tid
    }
}
