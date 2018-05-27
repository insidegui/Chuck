//
//  Collection+Shuffle.swift
//  ChuckCore
//
//  Created by Guilherme Rambo on 27/05/18.
//  Copyright © 2018 Guilherme Rambo. All rights reserved.
//

import Foundation

// Shuffle implementation courtesy of https://stackoverflow.com/questions/24026510/how-do-i-shuffle-an-array-in-swift

public extension MutableCollection {

    /// Shuffles the contents of this collection.
    mutating func shuffle() {
        let c = count
        guard c > 1 else { return }

        for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
            // Change `Int` in the next line to `IndexDistance` in < Swift 4.1
            let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
            let i = index(firstUnshuffled, offsetBy: d)
            swapAt(firstUnshuffled, i)
        }
    }

}

public extension Sequence {

    /// Returns an array with the contents of this sequence, shuffled.
    func shuffled() -> [Element] {
        var result = Array(self)
        result.shuffle()
        return result
    }

    func randomSelection(with amount: Int) -> [Element] {
        let effectiveCount = Swift.min(amount, underestimatedCount)
        let randomSlice = shuffled()[0..<effectiveCount]
        return Array(randomSlice)
    }

}
