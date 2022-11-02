//
//  Bank.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/23/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Foundation
import Mitra

/// A fictional Bank (an example of Mitra's shared memory manager usage)
struct Bank {
    let sharedManager = SharedManager()

    static let accountsCount = 10
    static let initialBalance = 50

    // MARK: - Properties (State)

    let accounts = (0..<accountsCount).map { _ in Property(value: initialBalance) }

    // MARK: - Commands

    func transfer(from fromAccount: Int, to toAccount: Int, amount: Int) {
        precondition(accounts.indices ~= fromAccount)
        precondition(accounts.indices ~= toAccount)
        sharedManager.borrow(
            ArraySliceProperty(accounts[fromAccount...fromAccount]).rw,
            ArraySliceProperty(accounts[toAccount...toAccount]).rw)
        { from, to in
            // Note: races for non-overlapping fromAccount->toAccount pairs are allowed!
            from.first!.value -= amount
            to.first!.value += amount
        }
    }

    // MARK: - Queries

    func report() -> [Int] {
        sharedManager.borrow(ArraySliceProperty(accounts).ro) { accounts in
            return accounts.map { $0.value }
        }
    }
}
