//
//  ProtocolSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class ProtocolSpec: TypeSpecImpl {
    public static let fieldModifiers: [Modifier] = [.Static]
    public static let methodModifiers: [Modifier] = [.Static]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: ProtocolSpecBuilder) {
        super.init(builder: b as TypeSpecBuilderImpl)
    }

    public static func builder(name: String) -> ProtocolSpecBuilder {
        return ProtocolSpecBuilder(name: name)
    }
}

public class ProtocolSpecBuilder: TypeSpecBuilderImpl, Builder {
    public typealias Result = ProtocolSpec
    public static let defaultConstruct: Construct = .Protocol

    public init(name: String) {
        super.init(name: name, construct: ProtocolSpecBuilder.defaultConstruct, methodSpecs: [MethodSpec](), fieldSpecs: [FieldSpec](), superProtocols: nil)
    }

    public func build() -> ProtocolSpec {
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
        super.addMethodSpec(methodSpec: methodSpec)
        methodSpec.parentType = self.construct
        return self
    }

    public func addFieldSpec(fieldSpec: FieldSpec) -> Self {
        super.addFieldSpec(fieldSpec)
        fieldSpec.parentType = .Enum
        return self
    }

    public func addFieldSpecs(fieldSpecList: [FieldSpec]) -> Self {
        fieldSpecList.forEach { addFieldSpec($0) }
        return self
    }

    public func addProtocol(protocolSpec: TypeName) -> Self {
        super.addProtocol(protocolSpec)
        return self
    }

    public func addProtocols(protocolList: [TypeName]) -> Self {
        super.addProtocols(protocolList)
        return self
    }

    public func addSuperType(superClass: TypeName) -> Self {
        super.addSuperType(superClass)
        return self
    }

    public func addModifier(m: Modifier) -> Self {
        guard (ProtocolSpec.asMemberModifiers.filter { $0 == m }).count == 1 else {
            return self
        }
        super.addModifier(internalMethod: m)
        return self
    }

    public func addModifiers(modifiers mList: [Modifier]) -> Self {
        mList.forEach { addModifier($0) }
        return self
    }

    public func addDescription(description: String?) -> Self {
        super.addDescription(description)
        return self
    }
}
