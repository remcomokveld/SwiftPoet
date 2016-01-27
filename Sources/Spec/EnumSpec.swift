//
//  EnumSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public class EnumSpec: TypeSpec {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Throws]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(builder: EnumSpecBuilder) {
        super.init(builder: builder as TypeSpecBuilder)
    }

    public static func builder(name: String) -> EnumSpecBuilder {
        return EnumSpecBuilder(name: name)
    }
}

public class EnumSpecBuilder: TypeSpecBuilder, Builder {
    public typealias Result = EnumSpec
    public static let defaultConstruct: Construct = .Enum

    private init(name: String) {
        super.init(name: name, construct: EnumSpecBuilder.defaultConstruct)
    }

    public func build() -> Result {
        return EnumSpec(builder: self)
    }
}

// MARK: Chaining
extension EnumSpecBuilder {

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

    public func addModifier(modifier: Modifier) -> Self {
        guard (EnumSpec.asMemberModifiers.filter { $0 == modifier }).count == 1 else {
            return self
        }
        super.addModifier(internalModifier: modifier)
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
