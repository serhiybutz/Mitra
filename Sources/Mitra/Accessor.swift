//
//  Accessor.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public struct Accessor<T> {
    private let prop: Property<T>
    internal init(_ p: Property<T>) {
        self.prop = p
    }
    public var value: T {
        get { prop.value }
        set { prop.value = newValue }
    }
}
