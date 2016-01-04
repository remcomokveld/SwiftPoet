//
//  ParameterSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public class ParameterSpec: PoetSpecImpl {
    public let type: TypeName

    private init(b: ParameterSpecBuilder) {
        self.type = b.type
        super.init(name: b.name, construct: b.construct, modifiers: b.modifiers, description: b.description)
    }

    public static func builder(name: String, type: TypeName, construct: Construct? = nil) -> ParameterSpecBuilder {
        return ParameterSpecBuilder(name: name, type: type, construct: construct)
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

public class ParameterSpecBuilder: SpecBuilderImpl, Builder {
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

    public func addModifier(m: Modifier) -> ParameterSpecBuilder {
        super.addModifier(internalMethod: m)
        return self
    }

    public func addModifiers(modifiers: [Modifier]) -> ParameterSpecBuilder {
        super.addModifiers(modifiers: modifiers)
        return self
    }

    public func addDescription(description: String?) -> ParameterSpecBuilder {
        super.addDescription(description)
        return self
    }
}
