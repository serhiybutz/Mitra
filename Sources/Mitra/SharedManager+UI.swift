//
//  SharedManager+UI.swift
//  Mitra
//
//  Created by Serge Bouts on 5/12/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension SharedManager {
    public func borrow<A, R>(_ a: Property<A>,
                             accessBlock: (inout Accessor<A>) -> R) -> R
    {
        var _a = Accessor(a)
        return internalBorrow([a]) {
            accessBlock(&_a)
        }
    }
    public func borrow<A, B, R>(_ a: Property<A>,
                                _ b: Property<B>,
                                accessBlock: (inout Accessor<A>,
                                              inout Accessor<B>) -> R) -> R
    {
        var _a = Accessor(a)
        var _b = Accessor(b)
        return internalBorrow([a, b]) {
            accessBlock(&_a, &_b)
        }
    }
    public func borrow<A, B, C, R>(_ a: Property<A>,
                                   _ b: Property<B>,
                                   _ c: Property<C>,
                                   accessBlock: (inout Accessor<A>,
                                                 inout Accessor<B>,
                                                 inout Accessor<C>) -> R) -> R
    {
        var _a = Accessor(a)
        var _b = Accessor(b)
        var _c = Accessor(c)
        return internalBorrow([a, b, c]) {
            accessBlock(&_a, &_b, &_c)
        }
    }
    public func borrow<A, B, C, D, R>(_ a: Property<A>,
                                      _ b: Property<B>,
                                      _ c: Property<C>,
                                      _ d: Property<D>,
                                      accessBlock: (inout Accessor<A>,
                                                    inout Accessor<B>,
                                                    inout Accessor<C>,
                                                    inout Accessor<D>) -> R) -> R
    {
        var _a = Accessor(a)
        var _b = Accessor(b)
        var _c = Accessor(c)
        var _d = Accessor(d)
        return internalBorrow([a, b, c, d]) {
            accessBlock(&_a, &_b, &_c, &_d)
        }
    }
    public func borrow<A, B, C, D, E, R>(_ a: Property<A>,
                                         _ b: Property<B>,
                                         _ c: Property<C>,
                                         _ d: Property<D>,
                                         _ e: Property<E>,
                                         accessBlock: (inout Accessor<A>,
                                                       inout Accessor<B>,
                                                       inout Accessor<C>,
                                                       inout Accessor<D>,
                                                       inout Accessor<E>) -> R) -> R
    {
        var _a = Accessor(a)
        var _b = Accessor(b)
        var _c = Accessor(c)
        var _d = Accessor(d)
        var _e = Accessor(e)
        return internalBorrow([a, b, c, d, e]) {
            accessBlock(&_a, &_b, &_c, &_d, &_e)
        }
    }
}
