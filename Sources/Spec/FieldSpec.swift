//
//  FieldSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public class FieldSpec: PoetSpecImpl {
    public let type: TypeName?
    public let initializer: CodeBlock?
    public var parentType: Construct?

    private init(b: FieldSpecBuilder) {
        self.type = b.type
        self.initializer = b.initializer
        self.parentType = b.parentType
        super.init(name: b.name, construct: b.construct, modifiers: b.modifiers, description: b.description, imports: b.imports)
    }

    public static func builder(name: String, type: TypeName? = nil, construct: Construct? = nil) -> FieldSpecBuilder {
        return FieldSpecBuilder(name: name, type: type, construct: construct)
    }

    public override func collectImports() -> Set<String> {
        var collectedImports = Set(imports)
        type?.collectImports().forEach { collectedImports.insert($0) }
        return collectedImports
    }

    public override func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        codeWriter.emitDocumentation(self)
        
        guard let parentType = parentType else {
            return codeWriter
        }

        switch parentType {
        case .Enum:
            emitEnumType(codeWriter)
            break

        case .Struct, .Class:
            emitClassType(codeWriter)
            break
        case .Protocol:
            emitProtocolType(codeWriter)
            break
        default:
            break
        }

        return codeWriter
    }

    private func emitEnumType(codeWriter: CodeWriter) {
        let cleanName = parentType == .Enum ? PoetUtil.cleanTypeName(name) : PoetUtil.cleanCammelCaseString(name)
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
        let cleanName = parentType == .Enum ? PoetUtil.cleanTypeName(name) : PoetUtil.cleanCammelCaseString(name)
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
        let cleanName = parentType == .Enum ? PoetUtil.cleanTypeName(name) : PoetUtil.cleanCammelCaseString(name)
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

public class FieldSpecBuilder: SpecBuilderImpl, Builder {
    public typealias Result = FieldSpec
    public static let defaultConstruct: Construct = .Field

    public let type: TypeName?

    private var _initializer: CodeBlock? = nil
    public var initializer: CodeBlock? {
        return _initializer
    }

    private var _parentType: Construct? = nil
    public var parentType: Construct? {
        return _parentType
    }

    private init(name: String, type: TypeName? = nil, construct: Construct? = nil) {
        self.type = type
        let c = construct == nil ? FieldSpecBuilder.defaultConstruct : construct!
        super.init(name: PoetUtil.cleanCammelCaseString(name), construct: c)
    }

    public func build() -> Result {
        return FieldSpec(b: self)
    }

}

// MARK: Add feild specific info
extension FieldSpecBuilder {

    public func addInitializer(i: CodeBlock) -> FieldSpecBuilder {
        self._initializer = i
        return self
    }

    public func addParentType(pt: Construct) -> FieldSpecBuilder {
        self._parentType = pt
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
        super.addModifiers(modifiers)
        return self
    }

    public func addDescription(description: String?) -> Self {
        super.addDescription(description)
        return self
    }

    public func addImport(imprt: String) -> Self {
        super.addImport(imprt)
        return self
    }

    public func addImports(imports: [String]) -> Self {
        super.addImports(imports)
        return self
    }
}
