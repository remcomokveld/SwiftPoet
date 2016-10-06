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
        return CodeBlock.builder().add(literal: self).build()
    }
}

extension String {
    public func cleaned(case _case: String.Case) -> String {
        switch _case {
        case .typeName:
            return ReservedWords.safeWord(PoetUtil.stripSpaceAndPunctuation(self).joined(separator: ""))
        case .paramName:
            let cleanedNameChars = PoetUtil.stripSpaceAndPunctuation(self).joined(separator: "")
            return ReservedWords.safeWord(PoetUtil.lowercaseFirstChar(cleanedNameChars))
        }
    }

    public enum Case {
        case typeName
        case paramName
    }
}
