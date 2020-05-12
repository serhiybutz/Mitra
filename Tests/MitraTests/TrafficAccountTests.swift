//
//  TrafficAccountTests.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
import XConcurrencyKit
@testable
import Mitra

// Tests for SharedManager races.
final class TrafficAccountTests: XCTestCase {
    let sut = TrafficAccountMock()

    func test_no_races() {
        // Given

        let threadCollider = ThreadCollider()

        // When

        threadCollider.collide(victim: {
            switch (0..<100).randomElement()! {
            case ..<10:
                self.sut.topUp(for: 40)
            case ..<85:
                _ = self.sut.consume(Double.random(in: 1...200), at: 0.1)
            case ..<90:
                _ = self.sut.currentBalance
            case ..<95:
                _ = self.sut.currentTraffic
            default:
                _ = self.sut.summary()
            }
        })

        // Then

        XCTAssertTrue(sut.raceDetector.noProblemDetected, "\(sut.raceDetector.exclusiveRaces + sut.raceDetector.nonExclusiveRaces) races out of \(sut.raceDetector.exclusivePasses + sut.raceDetector.nonExclusivePasses) passes")

        print(sut.summary())
    }
}
