//
//  ArraySliceProperty.swift
//  Mitra
//
//  Created by Serge Bouts on 6/23/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol AccessedArraySliceProperty: Accessed {
    associatedtype ValueType
}

/// Shared array slice property which needs to be invariant to multiple threads.
public struct ArraySliceProperty<T>: AccessedArraySliceProperty {
    public typealias ValueType = T

    // MARK: - State

    @usableFromInline
    let slice: ArraySlice<Property<T>>

    // MARK: - Initialization

    @inlinable
    public init(_ slice: ArraySlice<Property<T>>) {
        self.slice = slice
    }

    @inlinable
    public init(_ array: [Property<T>]) {
        self.slice = array[...]
    }

    // MARK: - Accessed

    @inline(__always)
    public func overlaps(with another: Accessed) -> Bool {
        guard let another = another as? Self else { return false }
        let clamped = slice.indices.clamped(to: another.slice.indices)
        guard !clamped.isEmpty else { return false }
        return slice[clamped].elementsEqual(another.slice[clamped], by: ===)
    }
}
