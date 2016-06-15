//
//  StringExtension.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/29/16.
//
//

import Foundation

extension String {
    public func toCodeBlock() -> CodeBlock {
        return CodeBlock.builder().addLiteral(any: self).build()
    }
}
