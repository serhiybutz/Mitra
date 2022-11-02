//
//  BankMock.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/23/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import Mitra
import XConcurrencyKit

/// A fictional Bank's mock
struct BankMock {
    let sharedManager = SharedManager()

    static let accountsCount = 10
    static let initialBalance = 50

    // MARK: - Properties (State)

    let accounts = (0..<accountsCount).map { _ in Property(value: initialBalance) }
    let raceDetector = RaceSensitiveSection()

    // MARK: - Commands

    func transfer(from fromAccount: Int, to toAccount: Int, amount: Int) {
        precondition(accounts.indices ~= fromAccount)
        precondition(accounts.indices ~= toAccount)
        sharedManager.borrow(
            ArraySliceProperty(accounts[fromAccount...fromAccount]).rw,
            ArraySliceProperty(accounts[toAccount...toAccount]).rw)
        { from, to in
            // Note: races for non-overlapping fromAccount->toAccount pairs are allowed!
            raceDetector.exclusiveCriticalSection({
                from.first!.value -= amount
                to.first!.value += amount

                // simulate some work
                let sleepVal = arc4random() & 15
                usleep(sleepVal)
            }, register: {
                $0(fromAccount)
                $0(toAccount)
            })
        }
    }

    // MARK: - Queries

    func report() -> [Int] {
        sharedManager.borrow(ArraySliceProperty(accounts).ro) { accounts in
            raceDetector.nonExclusiveCriticalSection({
                return accounts.map { $0.value }
            }, register: { register in
                accounts.indices.forEach { register($0) }
            })
        }
    }
}
