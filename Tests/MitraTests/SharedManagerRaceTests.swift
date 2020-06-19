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

        sut.borrow(foo.rw) { foo in
            foo.value = 0
        }
    }

    func test_race() {
        // Given

        let threadCollider = ThreadCollider()
        let raceDetector = RaceSensitiveSection()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            self.sut.borrow(self.foo.rw) { _ in
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

    func test_race_readsHaveRaces() {
        // Given

        let threadCollider = ThreadCollider()
        let raceDetector = RaceSensitiveSection()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            self.sut.borrow(self.foo.ro) { _ in
                raceDetector.exclusiveCriticalSection({
                    // simulate some work
                    let sleepVal = arc4random() & 7
                    usleep(sleepVal)
                })
            }

            // Race corral END
        })

        // Then

        XCTAssertFalse(raceDetector.noProblemDetected)
    }

    func test_race_mixedReadsWrites() {
        // Given

        let threadCollider = ThreadCollider()
        let raceDetector = RaceSensitiveSection()

        // When

        threadCollider.collide(victim: {
            // Race corral BEGIN

            if Bool.random() {
                self.sut.borrow(self.foo.rw) { _ in
                    raceDetector.exclusiveCriticalSection({
                        // simulate some work
                        let sleepVal = arc4random() & 7
                        usleep(sleepVal)
                    })
                }
            } else {
                self.sut.borrow(self.foo.ro) { _ in
                    raceDetector.nonExclusiveCriticalSection({
                        // simulate some work
                        let sleepVal = arc4random() & 7
                        usleep(sleepVal)
                    })
                }
            }

            // Race corral END
        })

        // Then

        XCTAssertTrue(raceDetector.noProblemDetected, "\(raceDetector.exclusiveRaces) races out of \(raceDetector.exclusivePasses) passes")
        XCTAssertTrue(raceDetector.nonExclusiveBenignRaces > 0)
        print("Read races: \(raceDetector.nonExclusiveRaces) out of \(raceDetector.nonExclusivePasses)")
    }
}
