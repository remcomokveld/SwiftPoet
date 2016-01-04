//
//  EmitObject.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/19/15.
//
//

import Foundation

public struct EmitObject {
    public let type: EmitType
    public let any: Any?

    public init(type: EmitType, any: Any? = nil) {
        self.type = type
        self.any = any
    }
}
