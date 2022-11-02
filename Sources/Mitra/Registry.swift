TODO: Implement a linked-list based borrowings registry instead of array-based, where each borrowable holds a reference to the first borrowing task (which holds the access type info), the first borrowing task holds a reference to the second borrowing task, and so on.

//
//  Registry.swift
//  Mitra
//
//  Created by Serhiy Butz on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Atomics

final class Registry: AtomicReference {
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
