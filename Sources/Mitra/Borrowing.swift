//
//  Borrowing.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Atomics
import Mutexes

final class Borrowing {
    final class RevokeCondition: AtomicReference {
        let mutex = PthreadMutex()
        let cond = PthreadCondition()
    }

    // MARK: - State

    // TODO: Condider using Set<Borrowable>
    private let props: ContiguousArray<Borrowable>
    private let hasRW: Bool

    let tid: UInt64

    private var atomicRevokeCondition = ManagedAtomic<RevokeCondition?>(nil)
    private var isRevoked = false

    // MARK: - Initialization

    @inline(__always)
    init(_ props: ContiguousArray<Borrowable>, _ tid: UInt64) {
        self.props = props
        self.hasRW = props.hasRWAccessSemantics
        self.tid = tid
    }

    deinit {
        revoke()
    }

    // MARK: - UI

    @inline(__always)
    func await() {
        var revokeCondition: RevokeCondition? = atomicRevokeCondition.load(ordering: .acquiring)
        if revokeCondition == nil {
            revokeCondition = RevokeCondition()
            let result = atomicRevokeCondition.compareExchange(expected: nil, desired: revokeCondition, successOrdering: .releasing, failureOrdering: .acquiring)
            if !result.exchanged {
                revokeCondition = result.original
            }
        }
        revokeCondition!.mutex.withLocked {
            while !isRevoked {
                revokeCondition!.cond.wait(with: revokeCondition!.mutex)
            }
        }
    }

    @inline(__always)
    func revoke() {
        isRevoked = true
        guard let revokeCondition = atomicRevokeCondition.load(ordering: .acquiring) else { return }
        revokeCondition.mutex.withLocked {
            revokeCondition.cond.broadcast()
        }
    }

    @inline(__always)
    func hasConfictWith(_ another: Borrowing) -> Bool {
        if !hasRW && !another.hasRW { return false } // minor optimization
        return props.withRWAccessSemantics
            .contains { a in another.props.contains { b in a.property.overlaps(with: b.property) } }
            ||
            another.props.withRWAccessSemantics
            .contains { a in props.contains { b in a.property.overlaps(with: b.property) } }
    }
}
