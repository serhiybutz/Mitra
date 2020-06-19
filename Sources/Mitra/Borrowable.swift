//
//  Borrowable.swift
//  Mitra
//
//  Created by Serge Bouts on 6/19/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

@usableFromInline
protocol Borrowable {
    var property: Accessed { get }
    var accessSemantics: AccessSemantics.Type { get }
}

extension ContiguousArray where Element == Borrowable {
    @inline(__always)
    var hasRWAccessSemantics: Bool {
        contains { $0.accessSemantics == RWAccessSemantics.self }
    }
    @inline(__always)
    var withRWAccessSemantics: Self {
        filter { $0.accessSemantics == RWAccessSemantics.self }
    }
}
