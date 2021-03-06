//
//  PoetUtil.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/12/15.
//
//

import Foundation

public struct PoetUtil {
    fileprivate static let template = "^^^^"
    fileprivate static let regexPattern = "\\s|_|\\.|-|\\[|\\]"
    
    fileprivate static var spaceAndPunctuationRegex: NSRegularExpression? {
        do {
            return try NSRegularExpression(pattern: PoetUtil.regexPattern, options: .anchorsMatchLines)
        } catch {
            return nil
        }
    }

    internal static func addUnique<T: Equatable>(_ data: T, to list: inout [T]) {
        if !list.contains(data) {
            list.append(data)
        }
    }

    internal static func stripSpaceAndPunctuation(_ name: String) -> [String] {
        guard let regex = spaceAndPunctuationRegex else {
            return [name]
        }

        return regex.stringByReplacingMatches(
            in: name, options: [],
            range: NSMakeRange(0, name.characters.count), withTemplate: template)
                .components(separatedBy: template)
                .map { capitalizeFirstChar($0) }
    }

    // capitalize first letter without removing cammel case on other characters
    internal static func capitalizeFirstChar(_ str: String) -> String {
        return caseFirstChar(str) {
            return $0.uppercased().characters
        }
    }

    // lowercase first letter without removing cammel case on other characters
    internal static func lowercaseFirstChar(_ str: String) -> String {
        return caseFirstChar(str) {
            return $0.lowercased().characters
        }
    }

    fileprivate static func caseFirstChar(_ str: String, caseFn: (_ str: String) -> String.CharacterView) -> String {
        guard str.characters.count > 0 else {
            return str // This does happen!
        }

        var chars = str.characters
        let first = str.substring(to: chars.index(after: chars.startIndex))
        let range = chars.startIndex..<chars.index(after: chars.startIndex)
        chars.replaceSubrange(range, with: caseFn(first))
        return String(chars)
    }

    public static func fmap<A, B>(_ data: A?, function: (A) -> B?) -> B? {
        switch data {
        case .some(let x): return function(x)
        case .none: return .none
        }
    }

    public static func fmap<A, B>(_ data: A?, function: (A) -> B) -> B? {
        switch data {
        case .some(let x): return function(x)
        case .none: return .none
        }
    }
}
