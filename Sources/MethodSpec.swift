//
//  MethodSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

public protocol MethodSpecProtocol {
    var typeVariables: [TypeName] { get }
    var throwsError: Bool { get }
    var returnType: TypeName? { get }
    var parameters: [ParameterSpec] { get }
    var codeBlock: CodeBlock? { get }
    var parentType: Construct? { get set}
}

public class MethodSpec: PoetSpec, MethodSpecProtocol {
    public let typeVariables: [TypeName]
    public let throwsError: Bool
    public let returnType: TypeName?
    public let parameters: [ParameterSpec]
    public let codeBlock: CodeBlock?
    public var parentType: Construct?

    private init(builder: MethodSpecBuilder) {
        self.typeVariables = builder.typeVariables
        self.throwsError = builder.throwsError
        self.returnType = builder.returnType
        self.parameters = builder.parameters
        self.codeBlock = builder.codeBlock
        self.parentType = builder.parentType

        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers,
                   description: builder.description, framework: builder.framework, imports: builder.imports)
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

    @discardableResult
    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        guard let parentType = parentType else {
            emitGeneralFunction(codeWriter: codeWriter)
            return codeWriter
        }

        switch parentType {
        case .Protocol:
            emitFunctionSigniture(codeWriter: codeWriter)
        default:
            emitGeneralFunction(codeWriter: codeWriter)
        }

        return codeWriter
    }

    private func emitGeneralFunction(codeWriter: CodeWriter) {
        emitFunctionSigniture(codeWriter: codeWriter)
        codeWriter.emit(type: .BeginStatement)
        if let codeBlock = codeBlock {
            codeWriter.emit(codeBlock: codeBlock)
        }
        codeWriter.emit(type: .EndStatement)
    }

    private func emitFunctionSigniture(codeWriter: CodeWriter) {
        codeWriter.emitDocumentation(forMethod: self)
        codeWriter.emitModifiers(modifiers: modifiers)

        let cbBuilder = CodeBlock.builder()
        if name != "init" {
            cbBuilder.addEmitObject(type: .Literal, any: construct)
        }
        cbBuilder.addEmitObject(type: .Literal, any: name)
        cbBuilder.addEmitObject(type: .Literal, any: "(")
        codeWriter.emit(codeBlock: cbBuilder.build())

        var first = true
        parameters.forEach { p in
            if !first {
                codeWriter.emit(type: .Literal, any: ", ")
            }
            p.emit(codeWriter: codeWriter)
            first = false
        }

        let _ = codeWriter.emit(type: .Literal, any: ")")

        if throwsError {
            codeWriter.emit(type: .Literal, any: " throws")
        }

        if let returnType = returnType {
            let returnBuilder = CodeBlock.builder()
            returnBuilder.addEmitObject(type: .Literal, any: " ->")
            returnBuilder.addEmitObject(type: .Literal, any: returnType)
            codeWriter.emit(codeBlock: returnBuilder.build())
        }
    }
}

public class MethodSpecBuilder: PoetSpecBuilder, Builder, MethodSpecProtocol {
    public typealias Result = MethodSpec
    public static let defaultConstruct: Construct = .Method

    public private(set) var typeVariables = [TypeName]()
    public private(set) var throwsError = false
    public private(set) var returnType: TypeName?
    public private(set) var parameters = [ParameterSpec]()
    public private(set) var codeBlock: CodeBlock?
    public var parentType: Construct?

    private init(name: String) {
        // init is a reserved word but is ok as a method name
        let cleanName = name == "init" ? name : name.cleaned(case: .ParamName)
        super.init(name: cleanName, construct: MethodSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        return MethodSpec(builder: self)
    }
}

// MARK: Add method spcific info
extension MethodSpecBuilder {

    @discardableResult
    public func add(typeVariable: TypeName) -> Self {
        PoetUtil.addUnique(data: typeVariable, toList: &typeVariables)
        return self
    }

    @discardableResult
    public func add(typeVariables: [TypeName]) -> Self {
        typeVariables.forEach { let _ = add(typeVariable: $0) }
        return self
    }

    @discardableResult
    public func add(returnType: TypeName) -> Self {
        self.returnType = returnType
        return self
    }

    @discardableResult
    public func add(parameter: ParameterSpec) -> Self {
        PoetUtil.addUnique(data: parameter, toList: &parameters)
        return self
    }

    @discardableResult
    public func add(parameters: [ParameterSpec]) -> Self {
        parameters.forEach { let _ = add(parameter: $0) }
        return self
    }

    @discardableResult
    public func add(codeBlock: CodeBlock) -> Self {
        self.codeBlock = CodeBlock.builder().addCodeBlock(codeBlock: codeBlock).build()
        return self
    }

    @discardableResult
    public func add(parentType: Construct) -> Self {
        self.parentType = parentType
        return self
    }

    @discardableResult
    public func add(throwable: Bool) -> Self {
        throwsError = throwable
        return self
    }
}

// MARK: Chaining
extension MethodSpecBuilder {

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
