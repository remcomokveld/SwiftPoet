//
//  Emitter.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol Emitter {
    func emit(codeWriter: CodeWriter) -> CodeWriter

    func toString() -> String
}

extension Emitter {
    public func toString() -> String {
        let cw = self.emit(CodeWriter())
        return cw.out
    }
}
