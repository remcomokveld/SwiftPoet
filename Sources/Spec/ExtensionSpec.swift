//
//  ExtensionSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/25/16.
//
//

import Foundation

public class ExtensionSpec: TypeSpec {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Override, .Required]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Throws, .Convenience, .Override, .Required]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: ExtensionSpecBuilder) {
        super.init(builder: b as TypeSpecBuilder)
    }

    public static func builder(name: String) -> ExtensionSpecBuilder {
        return ExtensionSpecBuilder(name: name)
    }
}

public class ExtensionSpecBuilder: TypeSpecBuilder, Builder {
    public typealias Result = ExtensionSpec
    public static let defaultConstruct: Construct = .Extension

    public init(name: String) {
        super.init(name: name, construct: ExtensionSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        return ExtensionSpec(b: self)
    }

}

// MARK: Chaining
extension ExtensionSpecBuilder {

    public func addMethodSpecs(methodSpecList: [MethodSpec]) -> Self {
        methodSpecList.forEach { self.addMethodSpec($0) }
        return self
    }

    public func addMethodSpec(methodSpec: MethodSpec) -> Self {
        super.addMethodSpec(internalMethodSpec: methodSpec)
        methodSpec.parentType = self.construct
        return self
    }

    public func addFieldSpec(fieldSpec: FieldSpec) -> Self {
        super.addFieldSpec(internalFieldSpec: fieldSpec)
        fieldSpec.parentType = .Enum
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
        guard (ExtensionSpec.asMemberModifiers.filter { $0 == m }).count == 1 else {
            return self
        }
        super.addModifier(internalModifier: m)
        return self
    }

    public func addModifiers(modifiers: [Modifier]) -> Self {
        modifiers.forEach { self.addModifier($0) }
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
