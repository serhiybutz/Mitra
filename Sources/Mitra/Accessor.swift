//
//  Accessor.swift
//  Mitra
//
//  Created by Serhiy Butz on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public struct Accessor<P: Accessed, S: AccessSemantics> {
    // MARK: - State

    @usableFromInline
    var property: P

    // MARK: - Initialization

    @usableFromInline @inline(__always)
    init(_ property: P) {
        self.property = property
    }
}
