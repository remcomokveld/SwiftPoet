//
//  EmitType.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/12/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif
public enum EmitType {
    case Literal
    case IncreaseIndentation
    case DecreaseIndentation
    case BeginStatement
    case EndStatement
    case NewLine
    case CodeLine
    case Emitter
}
