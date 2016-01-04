//
//  Construct.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public enum Construct {
    case Param
    case MutableParam
    case Field
    case MutableField
    case Method
    case Enum
    case Struct
    case Class
    case Protocol

    public var stringValue: String {
        switch self {
        case .Param: return ""
        case .MutableParam: return "var"
        case .Field: return "let"
        case .MutableField: return "var"
        case .Method: return "func"
        case .Enum: return "enum"
        case .Struct: return "struct"
        case .Class: return "class"
        case .Protocol: return "protocol"
        }
    }
}

extension Construct: Literal {
    public func literalValue() -> String {
        return self.stringValue
    }
}