//
//  Property.swift
//  Mitra
//
//  Created by Serhiy Butz on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol AccessedProperty: Accessed {
    associatedtype ValueType
}

/// Shared property (memory location) which needs to be invariant to multiple threads.
public final class Property<T>: AccessedProperty {
    public typealias ValueType = T

    // MARK: - State

    @usableFromInline
    var value: T

    // MARK: - Initialization

    @inlinable
    public init(value: T) {
        self.value = value
    }

    // MARK: - Accessed

    @inline(__always)
    public func overlaps(with another: Accessed) -> Bool {
        guard let another = another as? Self else { return false }
        return self === another
    }
}

extension Property: CustomStringConvertible where T: CustomStringConvertible {
    public var description: String {
        value.description
    }
}
