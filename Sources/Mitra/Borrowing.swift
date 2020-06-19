//
//  Borrowing.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mutexes

final class Borrowing {
    // MARK: - State

    private let props: ContiguousArray<Borrowable>
    private let hasRW: Bool
    private let revokeMutex = PthreadMutex()
    private let revokeCond = PthreadCondition()
    private var isRevoked = false

    // MARK: - Initialization

    @inline(__always)
    init(_ props: ContiguousArray<Borrowable>) {
        self.props = props
        self.hasRW = props.hasRWAccessSemantics
    }

    deinit {
        revoke()
    }

    // MARK: - UI

    @inline(__always)
    func wait() {
        revokeMutex.withLocked {
            while !isRevoked {
                revokeCond.wait(with: revokeMutex)
            }
        }
    }

    @inline(__always)
    func revoke() {
        revokeMutex.withLocked {
            if !isRevoked {
                isRevoked = true
                revokeCond.broadcast()
            }
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
