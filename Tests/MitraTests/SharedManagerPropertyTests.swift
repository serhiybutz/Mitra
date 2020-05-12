//
//  SharedManagerPropertyTests.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
@testable
import Mitra

final class SharedManagerPropertyTests: XCTestCase {
    let sut = SharedManager()

    func test_int() {
        // Given

        let foo = Property(value: 0)

        // When

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, 0)
            foo.value = 1
        }

        // Then

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, 1)
        }
    }

    func test_string() {
        // Given

        let foo = Property(value: "")

        // When

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, "")
            foo.value = "foo"
        }

        // Then

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, "foo")
        }
    }

    func test_optional() {
        // Given

        let foo = Property<Int?>(value: nil)

        // When

        sut.borrow(foo) { foo in
            XCTAssertNil(foo.value)
            foo.value = 1
        }

        // Then

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, 1)
        }
    }

    func test_array() {
        // Given

        let foo = Property<Array<Int>>(value: [])

        // When

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, [])
            foo.value = [1, 2]
            foo.value.append(3)
        }

        // Then

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, [1, 2, 3])
        }
    }

    func test_dictionary() {
        // Given

        let foo = Property<Dictionary<String, Int>>(value: [:])

        // When

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, [:])
            foo.value = ["foo": 2]
            foo.value["bar"] = 3
        }

        // Then

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, ["foo": 2, "bar": 3])
        }
    }

    func test_set() {
        // Given

        let foo = Property<Set<String>>(value: [])

        // When

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, [])
            foo.value = ["foo"]
            foo.value.insert("bar")
        }

        // Then

        sut.borrow(foo) { foo in
            XCTAssertEqual(foo.value, ["foo", "bar"])
        }
    }
}
