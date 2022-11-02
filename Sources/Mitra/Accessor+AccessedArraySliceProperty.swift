//
//  Accessor+AccessedArraySliceProperty.swift
//  Mitra
//
//  Created by Serhiy Butz on 6/23/20.
//  Copyright © 2020 iRiZen.com. All rights reserved.
//

extension Accessor: Sequence where P: AccessedArraySliceProperty {
    public typealias Element = Accessor<Property<P.ValueType>, S>
    public struct Iterator: IteratorProtocol {
        @usableFromInline
        var _iterator: IndexingIterator<ArraySlice<Property<P.ValueType>>>
        @inlinable
        public mutating func next() -> Accessor<Property<P.ValueType>, S>? {
            _iterator.next().map { Accessor<Property<P.ValueType>, S>($0) }
        }
        @inlinable
        init(_ sharedElementArraySlice: ArraySliceProperty<P.ValueType>) {
            self._iterator = sharedElementArraySlice.slice.makeIterator()
        }
    }
    @inlinable
    public func makeIterator() -> Iterator { Iterator(property as! ArraySliceProperty<P.ValueType>) }
}

extension Accessor: Collection where P: AccessedArraySliceProperty {
    public typealias Index = Int
    @inlinable
    public var startIndex: Int { (property as! ArraySliceProperty<P.ValueType>).slice.startIndex }
    @inlinable
    public var endIndex: Int { (property as! ArraySliceProperty<P.ValueType>).slice.endIndex }
    @inlinable
    public subscript(position: Int) -> Accessor<Property<P.ValueType>, S> {
        get { Accessor<Property<P.ValueType>, S>((property as! ArraySliceProperty<P.ValueType>).slice[position]) }
        set {} // tweak to suppress the compiler error "Cannot assign to property: subscript is get-only" on assignment
    }
    @inlinable
    public func index(after i: Int) -> Int {
        (property as! ArraySliceProperty<P.ValueType>).slice.index(after: i)
    }
    @inlinable
    public var first: Accessor<Property<P.ValueType>, S>? {
        get {
            let start = startIndex
            if start != endIndex { return self[start] }
            else { return nil }
        }
        set {} // tweak to suppress the compiler error "Left side of mutating operator isn't mutable: 'first' is a get-only property" on assignment
    }
}
