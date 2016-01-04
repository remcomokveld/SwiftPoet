//
//  Literal.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/12/15.
//
//

import Foundation

internal protocol Literal {
    func literalValue() -> String
}


extension String: Literal {
    func literalValue() -> String {
        return self
    }
}