//
//  Either.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/26/16.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

public enum Either<A, B> {
    case left(A)
    case right(B)
}
