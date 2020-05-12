//
//  Borrowing.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation

final class Borrowing {
    private let props: [AnyObject]
    private let revokeCond = NSCondition()
    private var isRevoked = false
    init(_ props: [AnyObject]) {
        self.props = props
    }
    func wait() {
        revokeCond.lock()
        defer { revokeCond.unlock() }
        while !isRevoked {
            revokeCond.wait()
        }
    }
    func revoke() {
        revokeCond.lock()
        defer { revokeCond.unlock() }
        if !isRevoked {
            isRevoked = true
            revokeCond.broadcast()
        }
    }
    func hasConfictWith(_ another: Borrowing) -> Bool {
        return props.contains { a in another.props.contains { b in a === b } }
    }
}

