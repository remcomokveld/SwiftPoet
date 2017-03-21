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
    public let data: Any?
    public let trimStart: Bool;

    public init(type: EmitType, data: Any? = nil, trimStart: Bool = false) {
        self.type = type
        self.data = data
        self.trimStart = trimStart
    }
}
