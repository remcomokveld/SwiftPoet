//
//  TypeName.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public class TypeName: Importable {
    public let keyword: String
    public let leftInnerType: TypeName? // for arrays or dictionaries
    public let rightInnerType: TypeName? // for dictionaries
    public let optional: Bool
    public var imports: Set<String>

    public init(keyword: String, optional: Bool = false, imports: [String]? = nil) {
        let trimKeyWord = keyword.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())

        if TypeName.isDictionary(trimKeyWord) {
            let chars = trimKeyWord.characters
            let range = Range(start: chars.startIndex.successor(), end: chars.endIndex.predecessor())
            let isOptional = TypeName.isOptional(trimKeyWord.substringWithRange(range))
            let endIndex = isOptional ? chars.endIndex.predecessor().predecessor() : chars.endIndex.predecessor()
            let splitIndex = trimKeyWord.rangeOfString(":")!.startIndex

            self.leftInnerType = TypeName(keyword: trimKeyWord.substringWithRange(Range(start: chars.startIndex.successor(), end: splitIndex)))
            self.rightInnerType = TypeName(keyword: trimKeyWord.substringWithRange(Range(start: splitIndex.successor(), end: endIndex)))
            self.keyword = PoetUtil.cleanTypeName("Dictionary")
            self.optional = isOptional || optional
            
        } else if TypeName.isArray(trimKeyWord) {
            let chars = trimKeyWord.characters
            var range = Range(start: chars.startIndex.successor(), end: chars.endIndex.predecessor())
            let isOptional = TypeName.isOptional(trimKeyWord.substringWithRange(range))
            range.endIndex = isOptional ? chars.endIndex.predecessor().predecessor() : chars.endIndex.predecessor()

            self.leftInnerType = TypeName(keyword: trimKeyWord.substringWithRange(range))
            self.rightInnerType = nil
            self.keyword = PoetUtil.cleanTypeName("Array")
            self.optional = isOptional || optional
        } else if TypeName.isOptional(trimKeyWord) {
            self.leftInnerType = nil
            self.rightInnerType = nil
            self.keyword = PoetUtil.cleanTypeName(trimKeyWord.substringToIndex(trimKeyWord.characters.endIndex.predecessor()))
            self.optional = true
        } else {
            self.leftInnerType = nil
            self.rightInnerType = nil
            self.keyword = PoetUtil.cleanTypeName(trimKeyWord)
            self.optional = optional
        }

        self.imports = imports?.reduce(Set<String>()) { (var dict, s) in dict.insert(s); return dict; } ?? Set<String>()
    }

    public func collectImports() -> Set<String> {
        var collectedImports = Set(imports)
        leftInnerType?.collectImports().forEach { collectedImports.insert($0) }
        rightInnerType?.collectImports().forEach { collectedImports.insert($0) }
        return collectedImports
    }

    public var isPrimitive: Bool {
        return keyword != TypeName.NilType.keyword
    }

    private static func isArray(keyword: String) -> Bool {
        var arrayMatch: NSRegularExpression?
        let range = NSRange(location: 0, length: keyword.characters.count)

        do {
            arrayMatch = try NSRegularExpression(pattern: "^\\[.+\\]\\??$", options: .CaseInsensitive)
        } catch {
            arrayMatch = nil // this should never happen
        }

        return arrayMatch?.numberOfMatchesInString(keyword, options: .Anchored, range: range) == 1
    }

    private static func isDictionary(keyword: String) -> Bool {
        var dictionaryMatch: NSRegularExpression?
        let range = NSRange(location: 0, length: keyword.characters.count)

        do {
            dictionaryMatch = try NSRegularExpression(pattern: "^\\[.+:.+\\]\\??$", options: .CaseInsensitive)
        } catch {
            dictionaryMatch = nil // this should never happen
        }

        return dictionaryMatch?.numberOfMatchesInString(keyword, options: .Anchored, range: range) == 1
    }

    private static func isOptional(keyword: String) -> Bool {
        var optionalMatch: NSRegularExpression?
        let range = NSRange(location: 0, length: keyword.characters.count)

        do {
            optionalMatch = try NSRegularExpression(pattern: "^\\w+\\?$", options: .CaseInsensitive)
        } catch {
            optionalMatch = nil // this should never happen
        }

        return optionalMatch?.numberOfMatchesInString(keyword, options: .Anchored, range: range) == 1
    }
}

extension TypeName: Equatable {}

public func ==(lhs: TypeName, rhs: TypeName) -> Bool {
    return lhs.optional == rhs.optional && lhs.keyword == rhs.keyword
}

extension TypeName: Hashable {
    public var hashValue: Int {
        return toString().hashValue
    }
}

extension TypeName: Emitter {
    public func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        return codeWriter.emit(.Literal, any: keyword)
    }

    public func toString() -> String {
        let cw = self.emit(CodeWriter())
        return cw.out
    }
}

extension TypeName: Literal {
    public func literalValue() -> String {
        if keyword == "_nil" {
            return "nil"
        }
        let optionalChar = optional ? "?" : ""
        if keyword == "Array" {
            return "[" + leftInnerType!.literalValue() + "]" + optionalChar
        } else if keyword == "Dictionary" {
            return "[" + leftInnerType!.literalValue() + ":" + rightInnerType!.literalValue() + "]" + optionalChar
        } else {
            return keyword + optionalChar
        }
    }
}

extension TypeName {
    public static let NilType = TypeName(keyword: "nil")
    public static let BooleanType = TypeName(keyword: "Bool")
    public static let IntegerType = TypeName(keyword: "Int")
    public static let DoubleType = TypeName(keyword: "Double")
    public static let AnyObjectType = TypeName(keyword: "AnyObject")
    public static let StringType = TypeName(keyword: "String")
    public static let NSDictionary = TypeName(keyword: "NSDictionary")

    // Optional
    public static let BooleanOptional = TypeName(keyword: "Bool", optional: true)
    public static let IntegerOptional = TypeName(keyword: "Int", optional: true)
    public static let DoubleOptional = TypeName(keyword: "Double", optional: true)
    public static let AnyObjectOptional = TypeName(keyword: "AnyObject", optional: true)
    public static let StringOptional = TypeName(keyword: "String", optional: true)
    public static let NSDictionaryOptional = TypeName(keyword: "NSDictionary", optional: true)
}
