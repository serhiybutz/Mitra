//
//  Contraption.swift
//  Mitra
//
//  Created by Serge Bouts on 11/16/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

import Mitra

/// A fictional device `Contraption` (an example of Mitra's shared memory manager usage)
struct Contraption {
    let sharedManager = SharedManager()

    // MARK: - Properties (State)

    private let sensorReadings = [Property(value: 0),
                                  Property(value: 0),
                                  Property(value: 0)]
    private let average = Property<Double>(value: 0.0)

    // MARK: - UI

    func updateSensor(_ i: Int, value: Int) {
        sharedManager.borrow(ArraySliceProperty(sensorReadings[i...i]).rw) { sensor in
            sensor.first!.value = value
        }
    }
    @discardableResult
    func updateAvarage() -> Double {
        sharedManager.borrow(ArraySliceProperty(sensorReadings[...]).ro, average.rw) { readings, average in
            average.value = Double(readings.map { $0.value }.reduce(0, +)) / Double(readings.count)
            // Alternatively:
            // average.value = Double(readings[0].value + readings[1].value + readings[2].value) / Double(readings.count)
            return average.value
        }
    }
}
