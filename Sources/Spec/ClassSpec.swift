//
//  ClassSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class ClassSpec: TypeSpecImpl {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Override, .Required]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Throws, .Convenience, .Override, .Required]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: ClassSpecBuilder) {
        super.init(builder: b as TypeSpecBuilderImpl)
    }

    public static func builder(name: String) -> ClassSpecBuilder {
        return ClassSpecBuilder(name: name)
    }
}

public class ClassSpecBuilder: TypeSpecBuilderImpl, Builder {
    public typealias Result = ClassSpec
    public static let defaultConstruct: Construct = .Class

    public init(name: String) {
        super.init(name: name, construct: ClassSpecBuilder.defaultConstruct, methodSpecs: [MethodSpec](), fieldSpecs: [FieldSpec](), superProtocols: [TypeName]())
    }

    public func build() -> Result {
        return ClassSpec(b: self)
    }

}

// MARK: Chaining
extension ClassSpecBuilder {

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
        guard (ClassSpec.asMemberModifiers.filter { $0 == m }).count == 1 else {
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
