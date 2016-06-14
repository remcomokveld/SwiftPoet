//
//  ParameterSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol ParameterSpecProtocol {
    var type: TypeName { get }
}

public class ParameterSpec: PoetSpec, ParameterSpecProtocol {
    public let type: TypeName

    private init(b: ParameterSpecBuilder) {
        self.type = b.type
        super.init(name: b.name, construct: b.construct, modifiers: b.modifiers, description: b.description, framework: b.framework, imports: b.imports)
    }

    public static func builder(name: String, type: TypeName, construct: Construct? = nil) -> ParameterSpecBuilder {
        return ParameterSpecBuilder(name: name, type: type, construct: construct)
    }

    public override func collectImports() -> Set<String> {
        return type.collectImports().union(imports)
    }

    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        if (construct == .MutableParam) {
            cbBuilder.addEmitObject(.Literal, any: construct)
        }
        cbBuilder.addEmitObject(.Literal, any: name)
        cbBuilder.addEmitObject(.Literal, any: ":")
        cbBuilder.addEmitObject(.Literal, any: type)
        codeWriter.emit(cbBuilder.build())
        return codeWriter
    }
}

public class ParameterSpecBuilder: PoetSpecBuilder, Builder, ParameterSpecProtocol {
    public typealias Result = ParameterSpec
    public static let defaultConstruct: Construct = .Param

    public let type: TypeName

    private init(name: String, type: TypeName, construct: Construct? = nil) {
        self.type = type
        let c = construct == nil || construct! != .MutableParam ? ParameterSpecBuilder.defaultConstruct : construct!
        super.init(name: PoetUtil.cleanCammelCaseString(name), construct: c)
    }

    public func build() -> Result {
        return ParameterSpec(b: self)
    }

}

// MARK: Chaining
extension ParameterSpecBuilder {

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
