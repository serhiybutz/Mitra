//
//  AccessSemantized.swift
//  Mitra
//
//  Created by Serge Bouts on 6/19/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public struct AccessSemantized<P: Accessed, S: AccessSemantics>: Borrowable {
    // MARK: - State

    @usableFromInline
    let p: P

    // MARK: - Initialization

    @inline(__always)
    public init(_ property: P) {
        self.p = property
    }

    // MARK: - Borrowable

    @usableFromInline @inline(__always)
    var property: Accessed { p }

    @usableFromInline @inline(__always)
    var accessSemantics: AccessSemantics.Type { S.self }
}
