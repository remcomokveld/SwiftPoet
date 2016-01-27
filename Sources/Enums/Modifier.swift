//
//  Modifier.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public enum Modifier: String {
    case Public = "public"
    case Private = "private"
    case Internal = "internal"

    case Static = "static"
    case Final = "final"
    case Klass = "class"

    case Mutating = "mutating"
    case Throws = "throws"
    case Convenience = "convenience"
    case Override = "override"
    case Required = "required"

    //    case DidSet
    //    case Lazy
    //    case WillSet
    //    case Weak
    //    case Optional

    public static func equivalentAccessLevel(parentModifiers pm: Set<Modifier>, childModifiers cm: Set<Modifier>) -> Bool {
        let parentAccessLevel = Modifier.accessLevel(pm)
        let childAccessLevel = Modifier.accessLevel(cm)

        if parentAccessLevel == .Private {
            return true
        } else if parentAccessLevel == .Internal && childAccessLevel != .Private {
            return true
        } else if parentAccessLevel == .Public && childAccessLevel == .Public {
            return true
        }
        return false
    }

    private static func accessLevel(modifiers: Set<Modifier>) -> Modifier {
        if modifiers.contains(.Private) {
            return .Private
        } else if modifiers.contains(.Public) {
            return .Public
        } else {
            return .Internal
        }
    }
}
