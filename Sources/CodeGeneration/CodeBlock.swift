//
//  CodeBlock.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public struct CodeBlock {
    
    private let _builder: CodeBlockBuilder
    public var emittableObjects: [Either<EmitObject, CodeBlock>] {
        return _builder.emittableObjects
    }

    public var isEmpty: Bool {
        return emittableObjects.isEmpty
    }

    private init(builder: CodeBlockBuilder) {
        self._builder = builder
    }

    public func toString() -> String {
        let codeWriter = CodeWriter()
        return codeWriter.emit(codeBlock: self).out
    }
    
    public func addCodeBlock(codeBlock: CodeBlock) -> CodeBlock {
        _builder.addCodeBlock(codeBlock: codeBlock)
        return self
    }
    
    public func addEmitObject(type: EmitType, any: Any? = nil) -> CodeBlock {
        _builder.addEmitObject(eo: EmitObject(type: type, any: any))
        return self
    }
    
    public func addLiteral(any: Literal) -> CodeBlock {
        _builder.addEmitObject(type: .Literal, any: any)
        return self
    }
    
    public func addCodeLine(any: Literal) -> CodeBlock {
        _builder.addEmitObject(type: .CodeLine, any: any)
        return self
    }
    
    public func addEmitObjects(emitObjects: [Either<EmitObject, CodeBlock>]) -> CodeBlock {
        _builder.emittableObjects.append(contentsOf: emitObjects)
        return self
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

    @discardableResult
    internal func addEmitObject(eo: EmitObject) -> CodeBlockBuilder {
        emittableObjects.append(Either.Left(eo))
        return self
    }

    @discardableResult
    public func addEmitObject(type: EmitType, any: Any? = nil) -> CodeBlockBuilder {
        return self.addEmitObject(eo: EmitObject(type: type, any: any))
    }

    @discardableResult
    public func addLiteral(any: Literal) -> CodeBlockBuilder {
        return self.addEmitObject(type: .Literal, any: any)
    }

    @discardableResult
    public func addCodeLine(any: Literal) -> CodeBlockBuilder {
        return self.addEmitObject(type: .CodeLine, any: any)
    }

    @discardableResult
    public func addEmitObjects(emitObjects: [Either<EmitObject, CodeBlock>]) -> CodeBlockBuilder {
        emittableObjects.append(contentsOf: emitObjects)
        return self
    }

    @discardableResult
    public func addCodeBlock(codeBlock: CodeBlock) -> CodeBlockBuilder {
        emittableObjects.append(Either.Right(codeBlock))
        return self
    }
}

