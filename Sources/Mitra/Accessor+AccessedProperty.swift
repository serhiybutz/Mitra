//
//  Accessor+AccessedProperty.swift
//  Mitra
//
//  Created by Serge Bouts on 6/19/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension Accessor where P: AccessedProperty, S == ROAccessSemantics {
    @inlinable @inline(__always)
    public var value: P.ValueType {
        (property as! Property<P.ValueType>).value
    }
}

extension Accessor where P: AccessedProperty, S == RWAccessSemantics {
    @inlinable @inline(__always)
    public var value: P.ValueType {
        mutating get { (property as! Property<P.ValueType>).value }
        set { (property as! Property<P.ValueType>).value = newValue }
    }
}
