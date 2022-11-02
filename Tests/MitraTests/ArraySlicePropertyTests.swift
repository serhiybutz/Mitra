//
//  ArraySlicePropertyTests.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/23/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
import XConcurrencyKit
@testable
import Mitra

final class ArraySlicePropertyTests: XCTestCase {
    let queue = DispatchQueue(label: "TestQueue", qos: .userInteractive, attributes: .concurrent)

    func test_1prop_that_thread_borrows_and_this_thread_waits1() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).rw) { foo in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                foo[foo.startIndex].value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).rw) { bar in
                XCTAssertEqual(bar[bar.startIndex].value, 1)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_1prop_that_thread_borrows_and_this_thread_waits2() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).rw) { foo in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                foo[foo.startIndex].value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).ro) { bar in
                XCTAssertEqual(bar[bar.startIndex].value, 1)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_1prop_that_thread_borrows_and_this_thread_noWaiting() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).ro) { foo in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                XCTAssertEqual(foo.first!.value, 0)
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).ro) { foo in
                XCTAssertEqual(foo.first!.value, 0)
            }
        }

        XCTAssertLessThanOrEqual(tm.executionTime, 0.1)
    }

    func test_1prop_that_thread_borrows_and_this_thread_waits3() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0), Property(value: 0), Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[1...1]).rw) { foo in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                foo[foo.startIndex].value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...2]).rw) { bar in
                XCTAssertEqual(bar[bar.startIndex].value, 0)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_1prop_that_thread_borrows_and_this_thread_waits4() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0), Property(value: 0), Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[1...1]).rw) { foo in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                foo[foo.startIndex].value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...2]).ro) { bar in
                XCTAssertEqual(bar[bar.startIndex].value, 0)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_1prop_that_thread_borrows_and_this_thread_noWaiting2() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0), Property(value: 0), Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[1...1]).ro) { _ in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...2]).ro) { foo in
//                XCTAssertEqual(foo[foo.startIndex].value, 0)
            }
        }

        XCTAssertLessThanOrEqual(tm.executionTime, 0.1)
    }

    func test_2prop_that_thread_borrows_and_this_thread_waits1() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0), Property(value: 0), Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).rw, ArraySliceProperty(array[2...2]).ro) { slice0, slice1 in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                slice0.first!.value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...2]).ro) { slice0 in
                XCTAssertEqual(slice0.first!.value, 1)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_2prop_that_thread_borrows_and_this_thread_waits2() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0), Property(value: 0), Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).ro, ArraySliceProperty(array[2...2]).rw) { slice0, slice1 in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                slice1.first!.value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...2]).ro) { slice0 in
                XCTAssertEqual(slice0[slice0.endIndex - 1].value, 1)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_2prop_that_thread_borrows_and_this_thread_noWaiting() {
        // Given

        let sharedManager = SharedManager()
        let array = [Property(value: 0), Property(value: 0), Property(value: 0)]

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            sharedManager.borrow(ArraySliceProperty(array[0...0]).ro, ArraySliceProperty(array[2...2]).ro) { slice0, slice1 in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sharedManager.borrow(ArraySliceProperty(array[0...2]).ro) { _ in }
        }

        XCTAssertLessThanOrEqual(tm.executionTime, 0.1)
    }
}
