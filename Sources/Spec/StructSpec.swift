//
//  StructSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class StructSpec: TypeSpec {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Mutating, .Throws]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: StructSpecBuilder) {
        super.init(builder: b as TypeSpecBuilder)
    }

    public static func builder(name: String) -> StructSpecBuilder {
        return StructSpecBuilder(name: name)
    }
}

public class StructSpecBuilder: TypeSpecBuilder, Builder {
    public typealias Result = StructSpec
    public static let defaultConstruct: Construct = .Struct
    private var includeInit: Bool = false

    public init(name: String) {
        super.init(name: name, construct: StructSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        if !(methodSpecs.contains { $0.name == "init" }) || includeInit {
            addInitMethod()
        }
        return StructSpec(b: self)
    }

    private func addInitMethod() -> Self {
        let mb = MethodSpec.builder("init")
        let cb = CodeBlock.builder()

        fieldSpecs.forEach { spec in
            if Modifier.equivalentAccessLevel(parentModifiers: self.modifiers, childModifiers: spec.modifiers) && !spec.modifiers.contains(.Static) {
                mb.addParameter(ParameterSpec.builder(spec.name, type: spec.type!)
                    .addModifiers(Array(spec.modifiers))
                    .addDescription(spec.description)
                    .build()
                )

                cb.addCodeBlock(CodeBlock.builder()
                    .addEmitObject(.Literal, any: "self.\(spec.name) = \(spec.name)")
                    .build()
                )
            }
        }

        mb.addCode(cb.build())

        return self.addMethodSpec(mb.build())
    }

    public func includeDefaultInit() -> StructSpecBuilder {
        includeInit = true
        return self;
    }
}

// MARK: Chaining
extension StructSpecBuilder {

    public func addMethodSpecs(methodSpecList: [MethodSpec]) -> Self {
        methodSpecList.forEach { self.addMethodSpec($0) }
        return self
    }

    public func addMethodSpec(methodSpec: MethodSpec) -> Self {
        super.addMethodSpec(internalMethodSpec: methodSpec)
        return self
    }

    public func addFieldSpec(fieldSpec: FieldSpec) -> Self {
        super.addFieldSpec(internalFieldSpec: fieldSpec)
        return self
    }

    public func addFieldSpecs(fieldSpecList: [FieldSpec]) -> Self {
        fieldSpecList.forEach { addFieldSpec($0) }
        return self
    }

    public func addProtocol(protocolSpec: TypeName) -> Self {
        super.addProtocol(internalProtocolSpec: protocolSpec)
        return self
    }

    public func addProtocols(protocolList: [TypeName]) -> Self {
        super.addProtocols(internalProtocolSpecList: protocolList)
        return self
    }

    public func addSuperType(superClass: TypeName) -> Self {
        super.addSuperType(internalSuperClass: superClass)
        return self
    }

    public func addModifier(m: Modifier) -> Self {
        guard StructSpec.asMemberModifiers.contains(m) else {
            return self
        }
        super.addModifier(internalModifier: m)
        return self
    }

    public func addModifiers(modifiers mList: [Modifier]) -> Self {
        mList.forEach { self.addModifier($0) }
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
