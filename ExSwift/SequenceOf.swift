//
//  Sequence.swift
//  ExSwift
//
//  Created by Colin Eberhardt on 24/06/2014.
//  Copyright (c) 2014 pNre. All rights reserved.
//

import Foundation

extension SequenceOf {

    /**
    *  First element of the sequence
    *  @return First element of the sequence if present
    */
    func first () -> T? {
        var generator =  self.generate();
        return generator.next()
    }
    
    /**
    *  First n elements of the sequence
    *  @param n Number of leading elements
    *  @return Array of first n elements
    */
    func first (n: Int) -> Array<T> {
        return self.take(n).toArray()
    }
    
    /**
    *  Checks if call returns true for any element of self
    *  @param call Function to call for each element
    *  @return True if call returns true for any element of self
    */
    func any (call: (T) -> Bool) -> Bool {
        for nextItem in self {
            if call(nextItem) {
                return true
            }
        }
        
        return false
    }
    
    /**
    *  Object at the specified index if exists
    *  @param index
    *  @return Object at index in sequence, nil if index is out of bounds
    */
    func get (index: Int) -> T? {
        var generator =  self.generate();
        for _ in 0..<(index - 1) {
            generator.next()
        }
        return generator.next()
    }
    
    /**
    *  Objects in the specified range
    *  @param range
    *  @return Subsequence in range
    */
    func get (range: Range<Int>) -> SequenceOf<T> {
        return self.skip(range.startIndex)
            .take(range.endIndex - range.startIndex)
    }
    
    /**
    *  Index of the first occurrence of item, if found
    *  @param item The item to search for
    *  @return Index of the matched item or nil
    */
    func indexOf <U: Equatable> (item: U) -> Int? {
        var index = 0;
        for current in self {
            if let equatable = current as? U {
                if equatable == item {
                    return index
                }
            }
            index++
        }
        return nil
    }
    
    /**
    *  Subsequence from n to the end of the sequence
    *  @return Sequence from n to the end
    */
    func skip (n:Int) -> SequenceOf<T> {
        var generator =  self.generate();
        for _ in 0..<n {
            generator.next()
        }
        return SequenceOf(generator)
    }
    
    /**
    *  Filters the sequence only including items that match the test
    *  @param include Function invoked to test elements for inclusion in the sequence
    *  @return Filtered sequence
    */
    func filter(include: (T) -> Bool) -> SequenceOf<T> {
        return SequenceOf(Swift.filter(self, include))
    }
    
    /**
    *  Maps each element of the sequence to another and collects them in the resulting sequence.
    *  @param transform Function invoked to get the mapped elements from the initial elements.
    *  @return Mapped sequence
    */
    func map<U> (transform: (T) -> U) -> SequenceOf<U> {
        return SequenceOf<U>(Swift.map(self, transform))
    }
    
    /**
    *  Equivalent to Array.reduce
    */
    func reduce<U> (initial: U, combine: (U, T) -> U) -> U {
        return Swift.reduce(self, initial, combine)
    }
    
    /**
    *  self.reduce() with initial value self.first()
    */
    func reduce (combine: (T, T) -> T) -> T {
        return Swift.reduce(self.skip(1), self.first()!, combine)
    }
    
    /**
    *  Opposite of filter
    *  @param exclude Function invoked to test elements for exlcusion from the sequence
    *  @return Filtered sequence
    */
    func reject (exclude: (T -> Bool)) -> SequenceOf<T> {
        return self.filter {
            return !exclude($0)
        }
    }
    
    /**
    *  Skips the elements in the sequence up until the condition returns false
    *  @param condition A function which returns a boolean if an element satisfies a given condition or not
    *  @return Elements of the sequence starting with the element which does not meet the condition
    */
    func skipWhile(condition:(T) -> Bool) -> SequenceOf<T> {
        var generator =  self.generate();
        var keepSkipping = true
        while keepSkipping {
            if let nextItem = generator.next() {
                keepSkipping = condition(nextItem)
            } else {
                keepSkipping = false
            }
        }
        return SequenceOf(generator)
    }
    
    /**
    *  Checks if self contains the item object
    *  @param item The item to search for
    *  @return true if self contains item
    */
    func contains<T:Equatable> (item: T) -> Bool {
        var generator =  self.generate();
        while let nextItem = generator.next() {
            if nextItem as T == item {
                return true;
            }
        }
        return false
    }

    /**
    *  Returns the first n elements from self
    *  @return First n elements
    */
    func take (n: Int) -> SequenceOf<T> {
        var count = 0
        var generator = self.generate()
        
        var takeGenerator = GeneratorOf<T> {
            if ++count <= n {
                return generator.next()
            } else {
                return nil
            }
        }
        return SequenceOf(takeGenerator)
    }
    
    /**
    *  Returns the elements of the sequence up until an element does not meet the condition
    *  @param condition A function which returns a boolean if an element satisfies a given condition or not.
    *  @return Elements of the sequence up until an element does not meet the condition
    */
    func takeWhile (condition:(T?) -> Bool) -> SequenceOf<T>  {
        var endConditionMet = false
        var generator = self.generate()
        
        var takeWhileGenerator = GeneratorOf<T> {
            if endConditionMet { return nil }
            let nextItem = generator.next()
            endConditionMet = !condition(nextItem)
            return endConditionMet ? nil : nextItem
        }
        return SequenceOf(takeWhileGenerator)
    }
    
    /**
    *  Converts self to array. Useful for method chaining.
    *  @return Array with elements of self.
    *  @note This method is not lazy, and will not work with infinite sequences.
    */
    func toArray() -> Array<T> {
        return Array(self)
    }
}