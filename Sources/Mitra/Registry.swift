//
//  Registry.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

final class Registry {
    // MARK: - State

    private var borrowings: ContiguousArray<Borrowing> = []

    // MARK: - UI

    @inline(__always)
    func copyWithAdded(_ borrowing: Borrowing) -> Registry {
        let new = Registry()
        new.borrowings = borrowings + [borrowing]
        return new
    }

    @inline(__always)
    func copyWithRemoved(_ borrowing: Borrowing) -> Registry {
        let new = Registry()
        new.borrowings = borrowings.filter { $0 !== borrowing }
        return new
    }

    @inline(__always)
    func searchForConflictingBorrowingWith(_ borrowing: Borrowing) -> Borrowing? {
        borrowings.first { borrowing.hasConfictWith($0) }
    }
}
