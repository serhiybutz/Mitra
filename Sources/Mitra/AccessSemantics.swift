//
//  AccessSemantics.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/19/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

public protocol AccessSemantics {}

public struct ROAccessSemantics: AccessSemantics {
    public init() {}
}

public struct RWAccessSemantics: AccessSemantics {
    public init() {}
}
