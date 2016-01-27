//
//  ProtocolSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class ProtocolSpec: TypeSpec {
    public static let fieldModifiers: [Modifier] = [.Static]
    public static let methodModifiers: [Modifier] = [.Static]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: ProtocolSpecBuilder) {
        super.init(builder: b as TypeSpecBuilder)
    }

    public static func builder(name: String) -> ProtocolSpecBuilder {
        return ProtocolSpecBuilder(name: name)
    }
}

public class ProtocolSpecBuilder: TypeSpecBuilder, Builder {
    public typealias Result = ProtocolSpec
    public static let defaultConstruct: Construct = .Protocol

    public init(name: String) {
        super.init(name: name, construct: ProtocolSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        return ProtocolSpec(b: self)
    }
}

// MARK: Chaining
extension ProtocolSpecBuilder {

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
        guard ProtocolSpec.asMemberModifiers.contains(m) else {
            return self
        }
        super.addModifier(internalModifier: m)
        return self
    }

    public func addModifiers(modifiers mList: [Modifier]) -> Self {
        mList.forEach { addModifier($0) }
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
