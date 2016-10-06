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
    public let data: Any?

    public init(type: EmitType, data: Any? = nil) {
        self.type = type
        self.data = data
    }
}
