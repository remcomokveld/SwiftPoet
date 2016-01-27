//
//  MethodSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public protocol MethodSpecProtocol {
    var typeVariables: [TypeName] { get }
    var throwsError: Bool { get }
    var returnType: TypeName? { get }
    var parameters: [ParameterSpec] { get }
    var code: CodeBlock? { get }
    var parentType: Construct? { get set}
}

public class MethodSpec: PoetSpec, MethodSpecProtocol {
    public let typeVariables: [TypeName]
    public let throwsError: Bool
    public let returnType: TypeName?
    public let parameters: [ParameterSpec]
    public let code: CodeBlock?
    public var parentType: Construct?

    private init(b: MethodSpecBuilder) {
        self.typeVariables = b.typeVariables
        self.throwsError = b.throwsError
        self.returnType = b.returnType
        self.parameters = b.parameters
        self.code = b.code
        self.parentType = b.parentType

        super.init(name: b.name, construct: b.construct, modifiers: b.modifiers, description: b.description, framework: b.framework, imports: b.imports)
    }

    public static func builder(name: String) -> MethodSpecBuilder {
        return MethodSpecBuilder(name: name)
    }

    public override func collectImports() -> Set<String> {
        let nestedImports = [
            typeVariables.reduce(Set<String>()) { set, t in
                return set.union(t.collectImports())
            },
            parameters.reduce(Set<String>()) { set, p in
                return set.union(p.collectImports())
            },
            returnType?.collectImports()
        ]
        return nestedImports.reduce(imports) { imports, list in
            guard let list = list else {
                return imports
            }
            return imports.union(list)
        }
    }

    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        guard let parentType = parentType else {
            emitGeneralFunction(codeWriter)
            return codeWriter
        }

        switch parentType {
        case .Protocol:
            emitFunctionSigniture(codeWriter)
        default:
            emitGeneralFunction(codeWriter)
        }

        return codeWriter
    }

    private func emitGeneralFunction(codeWriter: CodeWriter) {
        emitFunctionSigniture(codeWriter)
        codeWriter.emit(.BeginStatement)
        if let code = code {
            codeWriter.emit(code)
        }
        codeWriter.emit(.EndStatement)
    }

    private func emitFunctionSigniture(codeWriter: CodeWriter) {
        codeWriter.emitDocumentation(self)
        codeWriter.emitModifiers(modifiers)

        let cbBuilder = CodeBlock.builder()
        if name != "init" {
            cbBuilder.addEmitObject(.Literal, any: construct)
        }
        cbBuilder.addEmitObject(.Literal, any: name)
        cbBuilder.addEmitObject(.Literal, any: "(")
        codeWriter.emit(cbBuilder.build())

        var first = true
        parameters.forEach { p in
            if !first {
                codeWriter.emit(.Literal, any: ", ")
            }
            p.emit(codeWriter)
            first = false
        }

        codeWriter.emit(.Literal, any: ")")

        if throwsError {
            codeWriter.emit(.Literal, any: " throws")
        }

        if let returnType = returnType {
            let returnBuilder = CodeBlock.builder()
            returnBuilder.addEmitObject(.Literal, any: " ->")
            returnBuilder.addEmitObject(.Literal, any: returnType)
            codeWriter.emit(returnBuilder.build())
        }
    }
}

public class MethodSpecBuilder: SpecBuilder, Builder, MethodSpecProtocol {
    public typealias Result = MethodSpec
    public static let defaultConstruct: Construct = .Method

    public private(set) var typeVariables = [TypeName]()
    public private(set) var throwsError = false
    public private(set) var returnType: TypeName?
    public private(set) var parameters = [ParameterSpec]()
    public private(set) var code: CodeBlock?
    public var parentType: Construct?

    private init(name: String) {
        super.init(name: PoetUtil.cleanCammelCaseString(name), construct: MethodSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        return MethodSpec(b: self)
    }
}

// MARK: Add method spcific info
extension MethodSpecBuilder {

    public func addTypeVariable(type: TypeName) -> Self {
        PoetUtil.addDataToList(type, list: &typeVariables)
        return self
    }

    public func addTypeVariables(types: [TypeName]) -> Self {
        types.forEach { addTypeVariable($0) }
        return self
    }

    public func addReturnType(type: TypeName) -> Self {
        returnType = type
        return self
    }

    public func addParameter(parameter: ParameterSpec) -> Self {
        PoetUtil.addDataToList(parameter, list: &parameters)
        return self
    }

    public func addParameters(parameters: [ParameterSpec]) -> Self {
        parameters.forEach { addParameter($0) }
        return self
    }

    public func addCode(code: CodeBlock) -> Self {
        self.code = CodeBlock.builder().addCodeBlock(code).build()
        return self
    }

    public func addParentType(type: Construct) -> Self {
        parentType = type
        return self
    }

    public func canThrowError() -> Self {
        throwsError = true
        return self
    }
}

// MARK: Chaining
extension MethodSpecBuilder {

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
