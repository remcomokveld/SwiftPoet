//
//  CodeBlock.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public struct CodeBlock {
    public let emittableObjects: [Either<EmitObject, CodeBlock>]

    public var isEmpty: Bool {
        return emittableObjects.isEmpty
    }

    private init(builder: CodeBlockBuilder) {
        self.emittableObjects = builder.emittableObjects
    }

    public func toString() -> String {
        let codeWriter = CodeWriter()
        return codeWriter.emit(self).out
    }

    public static func builder() -> CodeBlockBuilder {
        return CodeBlockBuilder()
    }
}

extension CodeBlock: Equatable {}

public func ==(lhs: CodeBlock, rhs: CodeBlock) -> Bool {
    return lhs.toString() == rhs.toString()
}

extension CodeBlock: Hashable {
    public var hashValue: Int {
        return toString().hashValue
    }
}


public class CodeBlockBuilder: Builder {
    public typealias Result = CodeBlock

    public private(set) var emittableObjects = [Either<EmitObject, CodeBlock>]()

    private init () {}

    public func build() -> CodeBlock {
        return CodeBlock(builder: self)
    }

    internal func addEmitObject(eo: EmitObject) -> CodeBlockBuilder {
        emittableObjects.append(Either.Left(eo))
        return self
    }

    public func addEmitObject(type: EmitType, any: Any? = nil) -> CodeBlockBuilder {
        return self.addEmitObject(EmitObject(type: type, any: any))
    }

    public func addLiteral(any: Literal) -> CodeBlockBuilder {
        return self.addEmitObject(.Literal, any: any)
    }

    public func addCodeLine(any: Literal) -> CodeBlockBuilder {
        return self.addEmitObject(.CodeLine, any: any)
    }

    public func addEmitObjects(emitObjects: [Either<EmitObject, CodeBlock>]) -> CodeBlockBuilder {
        emittableObjects.appendContentsOf(emitObjects)
        return self
    }

    public func addCodeBlock(codeBlock: CodeBlock) -> CodeBlockBuilder {
        emittableObjects.append(Either.Right(codeBlock))
        return self
    }
}

