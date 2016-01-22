//
//  EmitType.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/12/15.
//
//

import Foundation

public enum EmitType {
    case Literal
    case Name
    case EscapedString
    case Modifiers
//    case Type
//    case DollarSign
    case IncreaseIndentation
    case DecreaseIndentation
    case BeginStatement
    case EndStatement
    case NewLine
    case Emitter
    case CodeLine
}