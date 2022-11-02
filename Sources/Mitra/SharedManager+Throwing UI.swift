//
//  SharedManager+Throwing UI.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/20/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension SharedManager {
    @inlinable @discardableResult
    public func borrow<A, AA: AccessSemantics, R>(_ a: AccessSemantized<A, AA>,
                                                  accessBlock: (inout Accessor<A, AA>) throws -> R) throws -> R {
        try internalBorrow([a]) {
            var _a = Accessor<A, AA>(a.p)
            return try accessBlock(&_a)
        }
    }

    @inlinable @discardableResult
    public func borrow<A, AA: AccessSemantics,
        B, BB: AccessSemantics, R>(_ a: AccessSemantized<A, AA>,
                                   _ b: AccessSemantized<B, BB>,
                                   accessBlock: (inout Accessor<A, AA>,
        inout Accessor<B, BB>) throws -> R) throws -> R
    {
        try internalBorrow([a,
                            b])
        {
            var _a = Accessor<A, AA>(a.p)
            var _b = Accessor<B, BB>(b.p)
            return try accessBlock(&_a,
                                   &_b)
        }
    }

    @inlinable @discardableResult
    public func borrow<A, AA: AccessSemantics,
        B, BB: AccessSemantics,
        C, CC: AccessSemantics, R>(_ a: AccessSemantized<A, AA>,
                                   _ b: AccessSemantized<B, BB>,
                                   _ c: AccessSemantized<C, CC>,
                                   accessBlock: (inout Accessor<A, AA>,
        inout Accessor<B, BB>,
        inout Accessor<C, CC>) throws -> R) throws -> R
    {
        try internalBorrow([a,
                            b,
                            c])
        {
            var _a = Accessor<A, AA>(a.p)
            var _b = Accessor<B, BB>(b.p)
            var _c = Accessor<C, CC>(c.p)
            return try accessBlock(&_a,
                                   &_b,
                                   &_c)
        }
    }

    @inlinable @discardableResult
    public func borrow<A, AA: AccessSemantics,
        B, BB: AccessSemantics,
        C, CC: AccessSemantics,
        D, DD: AccessSemantics, R>(_ a: AccessSemantized<A, AA>,
                                   _ b: AccessSemantized<B, BB>,
                                   _ c: AccessSemantized<C, CC>,
                                   _ d: AccessSemantized<D, DD>,
                                   accessBlock: (inout Accessor<A, AA>,
        inout Accessor<B, BB>,
        inout Accessor<C, CC>,
        inout Accessor<D, DD>) throws -> R) throws -> R
    {
        try internalBorrow([a,
                            b,
                            c,
                            d])
        {
            var _a = Accessor<A, AA>(a.p)
            var _b = Accessor<B, BB>(b.p)
            var _c = Accessor<C, CC>(c.p)
            var _d = Accessor<D, DD>(d.p)
            return try accessBlock(&_a,
                                   &_b,
                                   &_c,
                                   &_d)
        }
    }

    @inlinable @discardableResult
    public func borrow<A, AA: AccessSemantics,
        B, BB: AccessSemantics,
        C, CC: AccessSemantics,
        D, DD: AccessSemantics,
        E, EE: AccessSemantics, R>(_ a: AccessSemantized<A, AA>,
                                   _ b: AccessSemantized<B, BB>,
                                   _ c: AccessSemantized<C, CC>,
                                   _ d: AccessSemantized<D, DD>,
                                   _ e: AccessSemantized<E, EE>,
                                   accessBlock: (inout Accessor<A, AA>,
        inout Accessor<B, BB>,
        inout Accessor<C, CC>,
        inout Accessor<D, DD>,
        inout Accessor<E, EE>) throws -> R) throws -> R
    {
        try internalBorrow([a,
                            b,
                            c,
                            d,
                            e])
        {
            var _a = Accessor<A, AA>(a.p)
            var _b = Accessor<B, BB>(b.p)
            var _c = Accessor<C, CC>(c.p)
            var _d = Accessor<D, DD>(d.p)
            var _e = Accessor<E, EE>(e.p)
            return try accessBlock(&_a,
                                   &_b,
                                   &_c,
                                   &_d,
                                   &_e)
        }
    }
}
