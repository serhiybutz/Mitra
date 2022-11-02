//
//  Accessed.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/19/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol Accessed {
    func overlaps(with another: Accessed) -> Bool
}

extension Accessed {
    // MARK: - Access Semantics UI

    @inlinable @inline(__always)
    public var ro: AccessSemantized<Self, ROAccessSemantics> {
        AccessSemantized(self)
    }

    @inlinable @inline(__always)
    public var rw: AccessSemantized<Self, RWAccessSemantics> {
        AccessSemantized(self)
    }
}
