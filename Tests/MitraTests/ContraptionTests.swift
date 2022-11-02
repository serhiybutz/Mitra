//
//  ContraptionTests.swift
//  Mitra
//
//  Created by Serhiy Butz on 11/16/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import XCTest
import XConcurrencyKit
@testable
import Mitra

// Tests for SharedManager races
final class ContraptionTests: XCTestCase {
    let queue = DispatchQueue(label: "TestQueue", qos: .userInteractive, attributes: .concurrent)

    var sut: ContraptionMock!

    override func setUp() {
        super.setUp()
        sut = ContraptionMock()
    }

    func test_basics() {
        sut.updateSensor(0, value: 10)
        sut.updateSensor(1, value: 20)
        sut.updateSensor(2, value: 30)
        XCTAssertEqual(sut.updateAvarage(), 20)
    }

    func test_no_races() {
        // Given

        let threadCollider = ThreadCollider()

        // When

        threadCollider.collide(victim: {
            switch (0..<100).randomElement()! {
            case ..<95:
                self.sut.updateSensor(Int.random(in: 0..<self.sut.sensorReadings.count), value: Int.random(in: 0..<100))
            default:
                _ = self.sut.updateAvarage()
            }
        })

        // Then

        XCTAssertTrue(sut.sensorReadingsRaceDetector.noProblemDetected, "\(sut.sensorReadingsRaceDetector.exclusiveRaces + sut.sensorReadingsRaceDetector.nonExclusiveRaces) races out of \(sut.sensorReadingsRaceDetector.exclusivePasses + sut.sensorReadingsRaceDetector.nonExclusivePasses) passes")
    }
}
