//
//  Modifier.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

@objc public class Modifier: NSObject {

    public let rawString: String

    public init(rawString: String) {
        self.rawString = rawString
    }

    public static let Public = Modifier(rawString: "public")
    public static let Private = Modifier(rawString: "private")
    public static let Internal = Modifier(rawString: "internal")

    public static let Static = Modifier(rawString: "static")
    public static let Final = Modifier(rawString: "final")
    public static let Klass = Modifier(rawString: "class")

    public static let Mutating = Modifier(rawString: "mutating")
    public static let Throws = Modifier(rawString: "throws")
    public static let Convenience = Modifier(rawString: "convenience")
    public static let Override = Modifier(rawString: "override")
    public static let Required = Modifier(rawString: "required")

    public override var hashValue: Int {
        return rawString.hashValue
    }

    //    case DidSet
    //    case Lazy
    //    case WillSet
    //    case Weak
    //    case Optional

    public static func equivalentAccessLevel(parentModifiers pm: Set<Modifier>, childModifiers cm: Set<Modifier>) -> Bool {
        let parentAccessLevel = Modifier.accessLevel(modifiers: pm)
        let childAccessLevel = Modifier.accessLevel(modifiers: cm)

        if parentAccessLevel == .Private {
            return true
        } else if parentAccessLevel == .Internal && childAccessLevel != .Private {
            return true
        } else if parentAccessLevel == .Public && childAccessLevel == .Public {
            return true
        }
        return false
    }

    public static func accessLevel(modifiers: Set<Modifier>) -> Modifier {
        if modifiers.contains(.Private) {
            return .Private
        } else if modifiers.contains(.Public) {
            return .Public
        } else {
            return .Internal
        }
    }
}

public func ==(lhs: Modifier, rhs: Modifier) -> Bool {
    return lhs.rawString == rhs.rawString
}
