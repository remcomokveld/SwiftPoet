//
//  StringExtension.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/29/16.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

extension String {
    public func toCodeBlock() -> CodeBlock {
        return CodeBlock.builder().addLiteral(any: self).build()
    }
}

extension String {
    public func cleaned(case _case: String.Case) -> String {
        switch _case {
        case .TypeName:
            return ReservedWords.safeWord(word: PoetUtil.stripSpaceAndPunctuation(name: self).joined(separator: ""))
        case .ParamName:
            let cleanedNameChars = PoetUtil.stripSpaceAndPunctuation(name: self).joined(separator: "")
            return ReservedWords.safeWord(word: PoetUtil.lowercaseFirstChar(str: cleanedNameChars))
        }
    }

    public enum Case {
        case TypeName
        case ParamName
    }
}
