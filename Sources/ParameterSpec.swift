//
//  ParameterSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif
public protocol ParameterSpecProtocol {
    var type: TypeName { get }
}

public class ParameterSpec: PoetSpec, ParameterSpecProtocol {
    public let type: TypeName

    private init(builder: ParameterSpecBuilder) {
        self.type = builder.type
        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers,
                   description: builder.description, framework: builder.framework, imports: builder.imports)
    }

    public static func builder(name: String, type: TypeName, construct: Construct? = nil) -> ParameterSpecBuilder {
        return ParameterSpecBuilder(name: name, type: type, construct: construct)
    }

    public override func collectImports() -> Set<String> {
        return type.collectImports().union(imports)
    }

    @discardableResult
    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        if (construct == .MutableParam) {
            cbBuilder.addEmitObject(type: .Literal, any: construct)
        }
        cbBuilder.addEmitObject(type: .Literal, any: name)
        cbBuilder.addEmitObject(type: .Literal, any: ":")
        cbBuilder.addEmitObject(type: .Literal, any: type)
        codeWriter.emit(codeBlock: cbBuilder.build())
        return codeWriter
    }
}

public class ParameterSpecBuilder: PoetSpecBuilder, Builder, ParameterSpecProtocol {
    public typealias Result = ParameterSpec
    public static let defaultConstruct: Construct = .Param

    public let type: TypeName

    private init(name: String, type: TypeName, construct: Construct? = nil) {
        self.type = type
        let requiredConstruct = construct == nil || construct! != .MutableParam ? ParameterSpecBuilder.defaultConstruct : construct!
        super.init(name: name.cleaned(case: .ParamName), construct: requiredConstruct)
    }

    public func build() -> Result {
        return ParameterSpec(builder: self)
    }

}

// MARK: Chaining
extension ParameterSpecBuilder {

    @discardableResult
    public func add(modifier: Modifier) -> Self {
        mutatingAdd(modifier: modifier)
        return self
    }

    @discardableResult
    public func add(modifiers: [Modifier]) -> Self {
        mutatingAdd(modifiers: modifiers)
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
