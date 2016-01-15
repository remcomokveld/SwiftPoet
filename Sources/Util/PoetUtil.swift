//
//  PoetUtil.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/12/15.
//
//

import Foundation

public struct PoetUtil {
    private static let template = "^^^^"
    private static let regexPattern = "\\s|_|\\.|-"
    private static func getSpaceAndPunctuationRegex() -> NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: PoetUtil.regexPattern, options: NSRegularExpressionOptions.AnchorsMatchLines)
        } catch {
            return nil
        }
    }

    internal static func addDataToList<T: Equatable>(data: T, inout list: [T]) {
        if (list.filter { $0 == data }).count == 0 {
            list.append(data)
        }
    }

    internal static func addDataToList<T>(data: [T], fn: (T) -> Any) {
        for d in data { fn(d) }
    }

    // CapitalizedCammelCase
    public static func cleanTypeName(name: String) -> String {
        return ReservedWords.safeWord(PoetUtil.stripSpaceAndPunctuation(name).joinWithSeparator(""))
    }

    // cammelCase
    public static func cleanCammelCaseString(name: String) -> String {
        let cleanedNameChars = PoetUtil.stripSpaceAndPunctuation(name).joinWithSeparator("")
        return ReservedWords.safeWord(PoetUtil.lowercaseFirstChar(cleanedNameChars))
    }

    private static func stripSpaceAndPunctuation(name: String) -> [String] {
        guard let regex = getSpaceAndPunctuationRegex() else {
            return [name]
        }

        return regex.stringByReplacingMatchesInString(name, options: [], range: NSMakeRange(0, name.characters.count), withTemplate: PoetUtil.template).componentsSeparatedByString(PoetUtil.template).map { s in
            PoetUtil.capitalizeFirstChar(s)
        }
    }

    // capitalize first letter without removing cammel case on other characters
    private static func capitalizeFirstChar(str: String) -> String {
        return PoetUtil.caseFirstChar(str) { str in
            return str.uppercaseString.characters
        }
    }

    // lowercase first letter without removing cammel case on other characters
    private static func lowercaseFirstChar(str: String) -> String {
        return PoetUtil.caseFirstChar(str) { str in
            return str.lowercaseString.characters
        }
    }

    private static func caseFirstChar(str: String, caseFn: (str: String) -> String.CharacterView) -> String {
        guard str.characters.count > 0 else {
            return str // This does happen!
        }

        var chars = str.characters
        let first = str.substringToIndex(chars.startIndex.successor())
        let range = Range(start: chars.startIndex, end: chars.startIndex.successor())
        chars.replaceRange(range, with: caseFn(str: first))
        return String(chars)
    }

    internal static func fmap<A, B>(f: A -> B?, a: A?) -> B? {
        switch a {
        case .Some(let x): return f(x)
        case .None: return .None
        }
    }

    internal static func fmap<A, B>(f: A -> B, a: A?) -> B? {
        switch a {
        case .Some(let x): return f(x)
        case .None:   return .None
        }
    }
}

public enum Either<A, B> {
    case Left(A)
    case Right(B)
}
