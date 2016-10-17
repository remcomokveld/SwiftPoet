//
//  TypeName.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

open class TypeName: Importable {
    open let keyword: String
    open let leftInnerType: TypeName? // for arrays or dictionaries
    open let rightInnerType: TypeName? // for dictionaries
    open let optional: Bool
    open var imports: Set<String>

    public init(keyword: String, optional: Bool = false, imports: [String]? = nil) {
        let trimKeyWord = keyword.trimmingCharacters(in: .whitespaces)

        if TypeName.isObject(trimKeyWord) {
            self.keyword = "Dictionary"
            self.leftInnerType = TypeName.StringType
            self.rightInnerType = TypeName.StringType
            self.optional = optional
        } else if TypeName.isDictionary(trimKeyWord) {
            let chars = trimKeyWord.characters

            let isOptional = TypeName.isOptional(trimKeyWord)
            let endIndex = isOptional ? chars.index(chars.endIndex, offsetBy: -2) : chars.index(before: chars.endIndex)
            let splitIndex = trimKeyWord.range(of: ":")!.lowerBound//.startIndex //.rangeOfString(":")!.startIndex

            self.leftInnerType = TypeName(keyword: trimKeyWord.substring(with: chars.index(after: chars.startIndex)..<splitIndex))
            self.rightInnerType = TypeName(keyword: trimKeyWord.substring(with: chars.index(after: splitIndex)..<endIndex))
            self.keyword = "Dictionary".cleaned(.typeName)
            self.optional = isOptional || optional
            
        } else if TypeName.isArray(trimKeyWord) {
            let chars = trimKeyWord.characters
            let isOptional = TypeName.isOptional(trimKeyWord)
            let endIndex = isOptional ? chars.index(chars.endIndex, offsetBy: -2) : chars.index(before: chars.endIndex)
            let range = chars.index(after: chars.startIndex)..<endIndex

            self.leftInnerType = TypeName(keyword: trimKeyWord.substring(with: range))
            self.rightInnerType = nil
            self.keyword = "Array".cleaned(.typeName)
            self.optional = isOptional || optional

        } else if TypeName.isOptional(trimKeyWord) {

            self.leftInnerType = nil
            self.rightInnerType = nil
            let index = trimKeyWord.characters.index(before: trimKeyWord.characters.endIndex)
            self.keyword = trimKeyWord.substring(to: index).cleaned(.typeName)
            self.optional = true
        } else {
            self.leftInnerType = nil
            self.rightInnerType = nil
            self.keyword = trimKeyWord.cleaned(.typeName)
            self.optional = optional
        }

        self.imports = imports?.reduce(Set<String>()) { (dict, s) in var retVal = dict; retVal.insert(s); return retVal; } ?? Set<String>()
    }

    open func collectImports() -> Set<String> {
        var collectedImports = Set(imports)
        leftInnerType?.collectImports().forEach { collectedImports.insert($0) }
        rightInnerType?.collectImports().forEach { collectedImports.insert($0) }
        return collectedImports
    }

    open var isPrimitive: Bool {
        return keyword != TypeName.NilType.keyword
    }

    private static func isObject(_ keyword: String) -> Bool {
        return keyword.lowercased() == "object"
    }

    private static func isArray(_ keyword: String) -> Bool {
        var arrayMatch: NSRegularExpression?
        let range = NSRange(location: 0, length: keyword.characters.count)

        do {
            arrayMatch = try NSRegularExpression(pattern: "^\\[.+\\]\\??$", options: .caseInsensitive)
        } catch {
            arrayMatch = nil // this should never happen
        }

        return arrayMatch?.numberOfMatches(in: keyword, options: .anchored, range: range) == 1
    }

    private static func isDictionary(_ keyword: String) -> Bool {
        var dictionaryMatch: NSRegularExpression?
        let range = NSRange(location: 0, length: keyword.characters.count)

        do {
            dictionaryMatch = try NSRegularExpression(pattern: "^\\[.+:.+\\]\\??$", options: .caseInsensitive)
        } catch {
            dictionaryMatch = nil // this should never happen
        }

        return dictionaryMatch?.numberOfMatches(in: keyword, options: .anchored, range: range) == 1
    }

    private static func isOptional(_ keyword: String) -> Bool {
        var optionalMatch: NSRegularExpression?
        let range = NSRange(location: 0, length: keyword.characters.count)

        do {
            optionalMatch = try NSRegularExpression(pattern: "^.+\\?$", options: .caseInsensitive)
        } catch {
            optionalMatch = nil // this should never happen
        }

        return optionalMatch?.numberOfMatches(in: keyword, options: .anchored, range: range) == 1
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
    public func emit(to writer: CodeWriter) -> CodeWriter {
        return writer.emit(type: .literal, data: literalValue())
    }

    public func toString() -> String {
        let cw = self.emit(to: CodeWriter())
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
