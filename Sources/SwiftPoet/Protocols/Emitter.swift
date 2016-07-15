//
//  Emitter.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

@objc public protocol Emitter {
    @discardableResult
    func emit(codeWriter: CodeWriter) -> CodeWriter

    func toString() -> String
}
