//
//  Number+Clamping.swift
//  SwiftPong
//
//  Created by Edon Valdman on 3/23/24.
//

import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(range.lowerBound, self), range.upperBound)
    }
}
