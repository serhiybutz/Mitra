//
//  SharedManagerLogicTests.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
import XConcurrencyKit
@testable
import Mitra

final class SharedManagerLogicTests: XCTestCase {
    let queue = DispatchQueue(label: "TestQueue", qos: .userInteractive, attributes: .concurrent)

    var sut: SharedManager!

    let foo = Property(value: 0)
    let bar = Property(value: "")

    override func setUp() {
        super.setUp()
        sut = SharedManager()

        sut.borrow(foo.rw, bar.rw) { foo, bar in
            foo.value = 0
            bar.value = ""
        }
    }

    func test_shared_modified() {
        // Given

        sut.borrow(foo.ro, bar.ro) { foo, bar in
            XCTAssertEqual(foo.value, 0)
            XCTAssertEqual(bar.value, "")
        }

        // When

        sut.borrow(foo.rw, bar.rw) { foo, bar in
            foo.value = 1
            bar.value = "foo"
        }

        // Then

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, 1)
        }

        sut.borrow(bar.ro) { bar in
            XCTAssertEqual(bar.value, "foo")
        }
    }

    func test_1prop_that_thread_borrows_and_this_thread_waits() {
        // Given

        let barrier = DispatchSemaphore(value: 0)

        // When

        queue.async {
            self.sut.borrow(self.foo.rw) { foo in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                foo.value = 1
            }
        }

        // Then

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sut.borrow(foo.ro) { foo in
                XCTAssertEqual(foo.value, 1)
            }
        }

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_2pros_that_thread_borrows_and_this_thread_waits() {
        // Given

        let barrier = DispatchSemaphore(value: 0)
        queue.async {
            self.sut.borrow(self.foo.rw, self.bar.rw) { foo, bar in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                foo.value = 1
                bar.value = "foo"
            }
        }

        // When

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sut.borrow(bar.ro) { bar in
                // Then
                XCTAssertEqual(bar.value, "foo")
            }
        }

        // Then

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_2props_that_thread_borrows_and_this_thread_waits2() {
        // Given

        let barrier = DispatchSemaphore(value: 0)
        queue.async {
            self.sut.borrow(self.foo.ro, self.bar.rw) { foo, bar in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                bar.value = "foo"
            }
        }

        // When

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sut.borrow(bar.ro) { bar in
                // Then
                XCTAssertEqual(bar.value, "foo")
            }
        }

        // Then

        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_2props_that_thread_borrows_and_this_thread_waits3() {
        // Given

        let barrier = DispatchSemaphore(value: 0)
        queue.async {
            self.sut.borrow(self.foo.ro, self.bar.rw) { foo, bar in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                bar.value = "foo"
            }
        }

        // When

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sut.borrow(foo.ro, bar.ro) { foo, bar in
                // Then
                XCTAssertEqual(foo.value, 0)
                XCTAssertEqual(bar.value, "foo")
            }
        }

        // Then
        XCTAssertGreaterThanOrEqual(tm.executionTime, 1 - 0.1)
    }

    func test_2props_that_thread_borrows_and_this_thread_doesnt_wait() {
        // Given

        let barrier = DispatchSemaphore(value: 0)
        queue.async {
            self.sut.borrow(self.foo.ro, self.bar.rw) { foo, bar in
                barrier.signal()
                Thread.sleep(until: Date() + 1)
                bar.value = "foo"
            }
        }

        // When

        barrier.wait()
        var tm = MachExecutionTimeMeter()
        tm.measure {
            sut.borrow(foo.ro) { bar in
                // Then
                XCTAssertEqual(bar.value, 0)
            }
        }

        // Then

        XCTAssertLessThan(tm.executionTime, 1)
    }

    func test_1prop_2those_threads_wait_while_this_thread_borrows() {
        // Given

        let barrier1 = DispatchSemaphore.init(value: 0)
        let barrier2 = DispatchSemaphore(value: 0)
        let group = DispatchGroup()

        var tm1 = MachExecutionTimeMeter()
        var tm2 = MachExecutionTimeMeter()

        sut.borrow(foo.ro) { foo in
            XCTAssertEqual(foo.value, 0)
        }

        // When

        group.enter()
        queue.async {
            self.sut.borrow(self.foo.ro) { foo in
                XCTAssertEqual(foo.value, 0)
            }
            barrier1.signal()
            barrier2.wait()
            tm1.measure {
                self.sut.borrow(self.foo.ro) { foo in
                    // Then
                    XCTAssertEqual(foo.value, 123)
                }
            }
            group.leave()
        }

        group.enter()
        queue.async {
            self.sut.borrow(self.foo.ro) { foo in
                // Then
                XCTAssertEqual(foo.value, 0)
            }
            barrier1.signal()
            barrier2.wait()
            tm2.measure {
                // Then
                self.sut.borrow(self.foo.ro) { foo in
                    XCTAssertEqual(foo.value, 123)
                }
            }
            group.leave()
        }

        barrier1.wait()
        barrier1.wait()

        sut.borrow(foo.rw) { foo in
            barrier2.signal()
            barrier2.signal()
            Thread.sleep(until: Date() + 1)
            foo.value = 123
        }

        group.wait()

        // Then

        XCTAssertGreaterThanOrEqual(tm1.executionTime, 1 - 0.1)
        XCTAssertGreaterThanOrEqual(tm2.executionTime, 1 - 0.1)
    }
}
