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
    case literal
    case increaseIndentation
    case decreaseIndentation
    case beginStatement
    case endStatement
    case newLine
    case codeLine
    case emitter
}
