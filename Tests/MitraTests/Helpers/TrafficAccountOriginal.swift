//
//  TrafficAccountOriginal.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

/// A fictional traffic consumer account
final class TrafficAccountOriginal {
    // MARK: - Properties (State)

    private var balance: Double = 0 // remaining money
    private var traffic: Double = 0 // traffic consumed

    // MARK: - Queries

    public var currentBalance: Double { balance }
    public var currentTraffic: Double { traffic }
    public var summary: (balance: Double, traffic: Double) { (balance: balance, traffic: traffic) }

    // MARK: - Commands

    public func topUp(for amount: Double) {
        balance += amount
    }
    public func consume(_ gb: Double, at costPerGb: Double) -> Double {
        let cost = gb * costPerGb
        let spent = balance < cost ? balance : cost
        balance -= spent
        let consumed = spent / costPerGb
        traffic += consumed
        return consumed
    }
}
