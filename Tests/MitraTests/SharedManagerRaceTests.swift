//
//  SharedManagerRaceTests.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
import XConcurrencyKit
@testable
import Mitra

final class SharedManagerRaceTests: XCTestCase {
    var sut: SharedManager!

    let foo = Property(value: 0)

    override func setUp() {
        super.setUp()
        sut = SharedManager()

        sut.borrow(foo) { foo in
            foo.value = 0
        }
    }

    func test() {
        // Given

        let threadCollider = ThreadCollider()
        let raceDetector = RaceSensitiveSection()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            self.sut.borrow(self.foo) { _ in
                raceDetector.exclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 7
                    usleep(sleepVal)
                })
            }

            // Race corral END
        })

        // Then

        XCTAssertTrue(raceDetector.noProblemDetected, "\(raceDetector.exclusiveRaces + raceDetector.nonExclusiveRaces) races out of \(raceDetector.exclusivePasses + raceDetector.nonExclusivePasses) passes")
    }
}
