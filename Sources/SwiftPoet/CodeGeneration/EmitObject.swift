//
//  EmitObject.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/19/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

public struct EmitObject {
    public let type: EmitType
    public let any: Any?

    public init(type: EmitType, any: Any? = nil) {
        self.type = type
        self.any = any
    }
}
