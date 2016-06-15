//
//  FieldSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol FieldSpecType {
    var type: TypeName? { get }
    var initializer: CodeBlock? { get }
    var parentType: Construct? { get set }
    var associatedValues: [TypeName]? { get }
}

public class FieldSpec: PoetSpec, FieldSpecType {
    public let type: TypeName?
    public let initializer: CodeBlock?
    public var parentType: Construct?
    public var associatedValues: [TypeName]?

    private init(builder: FieldSpecBuilder) {
        self.type = builder.type
        self.initializer = builder.initializer
        self.parentType = builder.parentType
        self.associatedValues = builder.associatedValues
        super.init(name: builder.name, construct: builder.construct,
                   modifiers: builder.modifiers, description: builder.description,
                   framework: builder.framework, imports: builder.imports)
    }

    public static func builder(name: String, type: TypeName? = nil, construct: Construct? = nil) -> FieldSpecBuilder {
        return FieldSpecBuilder(name: name, type: type, construct: construct)
    }

    public override func collectImports() -> Set<String> {
        guard let nestedImports = type?.collectImports() else {
            return imports
        }
        return imports.union(nestedImports)
    }

    @discardableResult
    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        codeWriter.emitDocumentation(forField: self)
        
        guard let parentType = parentType else {
            return codeWriter
        }

        switch parentType {
        case .Enum where construct != .MutableParam:
            emitEnumType(codeWriter: codeWriter)
            break
        case .Struct, .Class, .Extension:
            emitClassType(codeWriter: codeWriter)
            break
        case .Protocol:
            emitProtocolType(codeWriter: codeWriter)
            break
        default:
            emitClassType(codeWriter: codeWriter)
        }

        return codeWriter
    }

    private func emitEnumType(codeWriter: CodeWriter) {
        let cleanName = name.cleaned(case: .TypeName)
        let cbBuilder = CodeBlock.builder()
                    .addEmitObject(type: .Literal, any: "case")
                    .addEmitObject(type: .Literal, any: cleanName)
        
        if let associatedValues = associatedValues {
            cbBuilder.addEmitObject(type: .Literal, any: "(")
            cbBuilder.addLiteral(any: associatedValues.map {
                return $0.toString()
            }.joined(separator: ","))
            cbBuilder.addEmitObject(type: .Literal, any: ")")
        }

        if let initializer = initializer {
            cbBuilder.addEmitObject(type: .Literal, any: "=")
            cbBuilder.addEmitObjects(emitObjects: initializer.emittableObjects)
        }

        codeWriter.emitWithIndentation(cb: cbBuilder.build())
    }

    private func emitClassType(codeWriter: CodeWriter) {
        let cleanName = construct == .TypeAlias ? name.cleaned(case: .TypeName) : name.cleaned(case: .ParamName)
        codeWriter.emitModifiers(modifiers: modifiers)
        let cbBuilder = CodeBlock.builder()
            .addEmitObject(type: .Literal, any: construct)
            .addEmitObject(type: .Literal, any: cleanName)

        if let type = type {
            cbBuilder.addEmitObject(type: .Literal, any: ":")
            cbBuilder.addEmitObject(type: .Literal, any: type)
        }

        if let initializer = initializer {
            if construct == .MutableField {
                cbBuilder.addEmitObject(type: .Literal, any: "=")
                cbBuilder.addEmitObjects(emitObjects: initializer.emittableObjects)
            } else if construct == .MutableParam {
                cbBuilder.addEmitObject(type: .BeginStatement)
                cbBuilder.addCodeBlock(codeBlock: initializer)
                cbBuilder.addEmitObject(type: .EndStatement)
            } else if construct == .TypeAlias && parentType != nil && parentType! == .Protocol {
                cbBuilder.addEmitObject(type: .Literal, any: ":")
                cbBuilder.addEmitObjects(emitObjects: initializer.emittableObjects)
            } else if construct == .TypeAlias {
                cbBuilder.addEmitObject(type: .Literal, any: "=")
                cbBuilder.addEmitObjects(emitObjects: initializer.emittableObjects)
            } else {
                fatalError()
            }
        }

        codeWriter.emit(codeBlock: cbBuilder.build())
    }

    private func emitProtocolType(codeWriter: CodeWriter) {
        let cleanName = parentType == .Enum || construct == .TypeAlias ? name.cleaned(case: .TypeName) : name.cleaned(case: .ParamName)
        codeWriter.emitModifiers(modifiers: modifiers)
        let cbBuilder = CodeBlock.builder()
            .addEmitObject(type: .Literal, any: construct)
            .addEmitObject(type: .Literal, any: cleanName)
            .addEmitObject(type: .Literal, any: ":")
            .addEmitObject(type: .Literal, any: type)

        if construct == .MutableField {
            cbBuilder.addEmitObject(type: .Literal, any: "{get set}")
        } else {
            cbBuilder.addEmitObject(type: .Literal, any: "{ get }")
        }

        codeWriter.emit(codeBlock: cbBuilder.build())
    }
}

public class FieldSpecBuilder: PoetSpecBuilder, Builder, FieldSpecType {
    private static let defaultConstruct: Construct = .Field
    
    public typealias Result = FieldSpec

    public let type: TypeName?
    public private(set) var initializer: CodeBlock? = nil
    public var parentType: Construct?
    public var associatedValues: [TypeName]?

    private init(name: String, type: TypeName? = nil, construct: Construct? = nil) {
        self.type = type
        let requiredConstruct = construct == nil ? FieldSpecBuilder.defaultConstruct : construct!
        super.init(name: name.cleaned(case: .ParamName), construct: requiredConstruct)
    }

    public func build() -> Result {
        return FieldSpec(builder: self)
    }
}

// MARK: Add field specific info
extension FieldSpecBuilder {
    @discardableResult
    public func add(initializer: CodeBlock) -> Self {
        self.initializer = initializer
        return self
    }

    @discardableResult
    public func add(parentType: Construct) -> Self {
        self.parentType = parentType
        return self
    }
}

// MARK: Chaining
extension FieldSpecBuilder {

    @discardableResult
    public func add(modifier: Modifier) -> Self {
        mutatingAdd(modifier: modifier)
        return self
    }

    @discardableResult
    public func add(modifiers: [Modifier]) -> Self {
        modifiers.forEach { mutatingAdd(modifier: $0) }
        return self
    }

    @discardableResult
    public func add(description: String?) -> Self {
        mutatingAdd(description: description)
        return self
    }

    @discardableResult
    public func add(framework: String?) -> Self {
        mutatingAdd(framework: framework)
        return self
    }

    @discardableResult
    public func add(import _import: String) -> Self {
        mutatingAdd(import: _import)
        return self
    }

    @discardableResult
    public func add(imports: [String]) -> Self {
        mutatingAdd(imports: imports)
        return self
    }
}

// MARK: Add enum specific info
extension FieldSpecBuilder {
    @discardableResult
    public func add(associatedValues: [TypeName]) -> Self {
        self.associatedValues = associatedValues
        return self
    }
}
