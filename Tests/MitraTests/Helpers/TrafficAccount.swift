//
//  TrafficAccount.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mitra

/// Traffic consumer account.
struct TrafficAccount {
    // MARK: - Properties (State)
    private let balance = Property<Double>(value: 0) // remaining money
    private let traffic = Property<Double>(value: 0) // traffic consumed

    private let sharedManager = SharedManager()

    // MARK: - Queries
    public var currentBalance: Double {
        sharedManager.borrow(balance) { $0.value }
    }
    public var currentTraffic: Double {
        sharedManager.borrow(traffic) { $0.value }
    }
    public var summary: (balance: Double, traffic: Double) {
        sharedManager.borrow(balance, traffic) { (balance: $0.value, traffic: $1.value) }
    }

    // MARK: - Commands
    public func topUp(for amount: Double) {
        sharedManager.borrow(balance) { $0.value += amount }
    }
    public func consume(_ gb: Double, at costPerGb: Double) -> Double {
        sharedManager.borrow(balance, traffic) { balance, traffic in
            let cost = gb * costPerGb
            let spent = balance.value < cost ? balance.value : cost
            balance.value -= spent
            let consumed = spent / costPerGb
            traffic.value += consumed
            return consumed
        }
    }
}