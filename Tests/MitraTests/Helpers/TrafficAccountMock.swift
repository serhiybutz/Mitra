//
//  TrafficAccountMock.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mitra
import XConcurrencyKit

// Mock of the traffic consumer account
struct TrafficAccountMock {
    // MARK: - State

    private let balance = Property<Double>(value: 0) // remaining money
    private let traffic = Property<Double>(value: 0) // traffic consumed
    private let sharedManager = SharedManager()

    let raceDetector = RaceSensitiveSection()

    // MARK: - Queries

    var currentBalance: Double {
        sharedManager.borrow(balance) { balance in
            raceDetector.nonExclusiveCriticalSection({
                return balance.value
            }, register: { $0(0) })
        }
    }

    var currentTraffic: Double {
        sharedManager.borrow(traffic) { traffic in
            raceDetector.nonExclusiveCriticalSection({
                return traffic.value
            }, register: { $0(1) })
        }
    }

    func summary() -> (balance: Double, traffic: Double) {
        sharedManager.borrow(balance, traffic) { balance, traffic in
            raceDetector.nonExclusiveCriticalSection({
                return (balance: balance.value, traffic: traffic.value)
            }, register: { register in [0, 1].forEach { register($0) } })
        }
    }

    // MARK: - Commands

    func topUp(for amount: Double) {
        sharedManager.borrow(balance) { balance in
            raceDetector.exclusiveCriticalSection({
                balance.value += amount
            }, register: { $0(0) })
        }
    }

    func consume(_ gb: Double, at costPerGb: Double) -> Double {
        sharedManager.borrow(balance, traffic) { balance, traffic in
            raceDetector.exclusiveCriticalSection({
                let cost = gb * costPerGb
                let spent = balance.value < cost ? balance.value : cost
                balance.value -= spent
                let consumed = spent / costPerGb
                traffic.value += consumed
                return consumed
            }, register: { register in [0, 1].forEach { register($0) } })
        }
    }
}
