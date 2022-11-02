//
//  ContraptionMock.swift
//  Mitra
//
//  Created by Serhiy Butz on 11/16/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mitra
import XConcurrencyKit

/// A fictional device `Contraption`'s mock
struct ContraptionMock {
    let sharedManager = SharedManager()

    let sensorReadingsRaceDetector = RaceSensitiveSection()

    // MARK: - Properties (State)

    let sensorReadings = [Property(value: 0),
                                  Property(value: 0),
                                  Property(value: 0)]
    let average = Property<Double>(value: 0.0)

    // MARK: - UI

    func updateSensor(_ i: Int, value: Int) {
        sharedManager.borrow(ArraySliceProperty(sensorReadings[i...i]).rw) { sensor in
            sensorReadingsRaceDetector.exclusiveCriticalSection({
                sensor.first!.value = value
            }, register: { $0(i) })
        }
    }
    @discardableResult
    func updateAvarage() -> Double {
        sharedManager.borrow(ArraySliceProperty(sensorReadings[...]).ro, average.rw) { readings, average in
            sensorReadingsRaceDetector.nonExclusiveCriticalSection({
                average.value = Double(readings.map { $0.value }.reduce(0, +)) / Double(readings.count)
                // Alternatively:
                // average.value = Double(readings[0].value + readings[1].value + readings[2].value) / Double(readings.count)
                return average.value
            }, register: { register in readings.indices.forEach { register($0) } })
        }
    }
}
