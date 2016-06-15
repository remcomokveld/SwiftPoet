//
//  Builder.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

public protocol Builder {
    associatedtype Result

    func build() -> Result
}
