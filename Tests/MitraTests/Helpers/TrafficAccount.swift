//
//  TrafficAccount.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mitra

/// A fictional traffic consumer account (an example of Mitra's shared memory manager usage)
struct TrafficAccount {
    let sharedManager = SharedManager()

    // MARK: - Properties (State)

    private let balance = Property<Double>(value: 0) // remaining money
    private let traffic = Property<Double>(value: 0) // traffic consumed

    // MARK: - Queries

    public var currentBalance: Double {
        sharedManager.borrow(balance.ro) { $0.value }
    }
    public var currentTraffic: Double {
        sharedManager.borrow(traffic.ro) { $0.value }
    }
    public var summary: (balance: Double, traffic: Double) {
        sharedManager.borrow(balance.ro, traffic.ro) { (balance: $0.value, traffic: $1.value) }
    }

    // MARK: - Commands

    public func topUp(for amount: Double) {
        sharedManager.borrow(balance.rw) { $0.value += amount }
    }
    public func consume(_ gb: Double, at costPerGb: Double) -> Double {
        sharedManager.borrow(balance.rw, traffic.rw) { balance, traffic in
            let cost = gb * costPerGb
            let spent = balance.value < cost ? balance.value : cost
            balance.value -= spent
            let consumed = spent / costPerGb
            traffic.value += consumed
            return consumed
        }
    }
}
