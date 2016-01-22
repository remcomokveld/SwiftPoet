//
//  Emitter.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol Emitter {
    func emit(codeWriter: CodeWriter, asFile: Bool) -> CodeWriter

    func toString() -> String
}

extension Emitter {
    public func toString() -> String {
        return self.emit(CodeWriter(), asFile: false).out
    }
}
