//
//  FieldSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol FieldSpecProtocol {
    var type: TypeName? { get }
    var initializer: CodeBlock? { get }
    var parentType: Construct? { get set }
}

public class FieldSpec: PoetSpec, FieldSpecProtocol {
    public let type: TypeName?
    public let initializer: CodeBlock?
    public var parentType: Construct?

    private init(b: FieldSpecBuilder) {
        self.type = b.type
        self.initializer = b.initializer
        self.parentType = b.parentType
        super.init(name: b.name, construct: b.construct, modifiers: b.modifiers, description: b.description, framework: b.framework, imports: b.imports)
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

    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        codeWriter.emitDocumentation(self)
        
        guard let parentType = parentType else {
            return codeWriter
        }

        switch parentType {
        case .Enum:
            emitEnumType(codeWriter)
            break

        case .Struct, .Class, .Extension:
            emitClassType(codeWriter)
            break
        case .Protocol:
            emitProtocolType(codeWriter)
            break
        default:
            fatalError()
        }

        return codeWriter
    }

    private func emitEnumType(codeWriter: CodeWriter) {
        let cleanName = parentType == .Enum || construct == .TypeAlias ? PoetUtil.cleanTypeName(name) : PoetUtil.cleanCammelCaseString(name)
        let cbBuilder = CodeBlock.builder()
                    .addEmitObject(.Literal, any: "case")
                    .addEmitObject(.Literal, any: cleanName)

        if let initializer = initializer {
            cbBuilder.addEmitObject(.Literal, any: "=")
            cbBuilder.addEmitObjects(initializer.emittableObjects)
        }

        codeWriter.emitWithIndentation(cbBuilder.build())
    }

    private func emitClassType(codeWriter: CodeWriter) {
        let cleanName = parentType == .Enum || construct == .TypeAlias ? PoetUtil.cleanTypeName(name) : PoetUtil.cleanCammelCaseString(name)
        codeWriter.emitModifiers(modifiers)
        let cbBuilder = CodeBlock.builder()
            .addEmitObject(.Literal, any: construct)
            .addEmitObject(.Literal, any: cleanName)

        if let type = type {
            cbBuilder.addEmitObject(.Literal, any: ":")
            cbBuilder.addEmitObject(.Literal, any: type)
        }

        if let initializer = initializer {
            if construct == .MutableField {
                cbBuilder.addEmitObject(.Literal, any: "=")
                cbBuilder.addEmitObjects(initializer.emittableObjects)
            } else if construct == .MutableParam {
                cbBuilder.addEmitObject(.BeginStatement)
                cbBuilder.addCodeBlock(initializer)
                cbBuilder.addEmitObject(.EndStatement)
            } else if construct == .TypeAlias && parentType != nil && parentType! == .Protocol {
                cbBuilder.addEmitObject(.Literal, any: ":")
                cbBuilder.addEmitObjects(initializer.emittableObjects)
            } else if construct == .TypeAlias {
                cbBuilder.addEmitObject(.Literal, any: "=")
                cbBuilder.addEmitObjects(initializer.emittableObjects)
            } else {
                fatalError()
            }
        }

        codeWriter.emit(cbBuilder.build())
    }

    private func emitProtocolType(codeWriter: CodeWriter) {
        let cleanName = parentType == .Enum || construct == .TypeAlias ? PoetUtil.cleanTypeName(name) : PoetUtil.cleanCammelCaseString(name)
        codeWriter.emitModifiers(modifiers)
        let cbBuilder = CodeBlock.builder()
            .addEmitObject(.Literal, any: construct)
            .addEmitObject(.Literal, any: cleanName)
            .addEmitObject(.Literal, any: ":")
            .addEmitObject(.Literal, any: type)

        if construct == .MutableField {
            cbBuilder.addEmitObject(.Literal, any: "{get set}")
        } else {
            cbBuilder.addEmitObject(.Literal, any: "{ get }")
        }

        codeWriter.emit(cbBuilder.build())
    }
}

public class FieldSpecBuilder: SpecBuilder, Builder, FieldSpecProtocol {
    private static let defaultConstruct: Construct = .Field
    
    public typealias Result = FieldSpec
    public let type: TypeName?
    public private(set) var initializer: CodeBlock? = nil
    public var parentType: Construct?

    private init(name: String, type: TypeName? = nil, construct: Construct? = nil) {
        self.type = type
        let c = construct == nil ? FieldSpecBuilder.defaultConstruct : construct!
        super.init(name: PoetUtil.cleanCammelCaseString(name), construct: c)
    }

    public func build() -> Result {
        return FieldSpec(b: self)
    }

}

// MARK: Add field specific info
extension FieldSpecBuilder {
    public func addInitializer(i: CodeBlock) -> Self {
        self.initializer = i
        return self
    }

    public func addParentType(pt: Construct) -> Self {
        self.parentType = pt
        return self
    }
}

// MARK: Chaining
extension FieldSpecBuilder {

    public func addModifier(m: Modifier) -> Self {
        super.addModifier(internalModifier: m)
        return self
    }

    public func addModifiers(modifiers: [Modifier]) -> Self {
        super.addModifiers(internalModifiers: modifiers)
        return self
    }

    public func addDescription(description: String?) -> Self {
        super.addDescription(internalDescription: description)
        return self
    }

    public func addFramework(framework: String?) -> Self {
        super.addFramework(internalFramework: framework)
        return self
    }

    public func addImport(imprt: String) -> Self {
        super.addImport(internalImport: imprt)
        return self
    }

    public func addImports(imports: [String]) -> Self {
        super.addImports(internalImports: imports)
        return self
    }
}
