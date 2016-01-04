//
//  PoetUtil.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/12/15.
//
//

import Foundation

internal struct PoetUtil {
    static func addDataToList<T: Equatable>(data: T, inout list: [T]) {
        if (list.filter { $0 == data }).count == 0 {
            list.append(data)
        }
    }

    static func addDataToList<T>(data: [T], fn: (T) -> Any) {
        for d in data { fn(d) }
    }

    static func cleanTypeName(name: String) -> String {
        let cleanedName = PoetUtil.stripSpaceAndUnderscore(name).reduce("") { accum, str in
            return accum + PoetUtil.capitalizeFirstChar(str)
        }

        return ReservedWords.safeWord(cleanedName)
    }

    static func cleanCammelCaseString(name: String) -> String {
        guard name.characters.count > 0 else {
            return name
        }

        var cleanedNameChars = PoetUtil.stripSpaceAndUnderscore(name).reduce("") { accum, str in
                return accum + PoetUtil.capitalizeFirstChar(str)
        }.characters

        let lowercaseStr = String(cleanedNameChars.first!).lowercaseString.characters
        let range = Range(start: cleanedNameChars.startIndex, end: cleanedNameChars.startIndex.successor())
        cleanedNameChars.replaceRange(range, with: lowercaseStr)

        return ReservedWords.safeWord(String(cleanedNameChars))
    }

    private static func stripSpaceAndUnderscore(name: String) -> [String] {
        let chars = name.characters

        // if name doens not have spaces or underscores, assume it is already cleaned
        guard chars.contains(" ") || chars.contains("_")  else {
            return [name]
        }

        return chars.split { str in
            str == " " || str == "_"
        }.map {
            String($0).lowercaseString
        }
    }

    // capitalize first letter without removing cammel case on other characters
    private static func capitalizeFirstChar(str: String) -> String {
        var chars = str.characters
        let first = str.substringToIndex(chars.startIndex.successor())
        let range = Range(start: chars.startIndex, end: chars.startIndex.successor())
        chars.replaceRange(range, with: first.capitalizedString.characters)
        return String(chars)
    }

    static func fmap<A, B>(f: A -> B?, a: A?) -> B? {
        switch a {
        case .Some(let x): return f(x)
        case .None: return .None
        }
    }

    static func fmap<A, B>(f: A -> B, a: A?) -> B? {
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
