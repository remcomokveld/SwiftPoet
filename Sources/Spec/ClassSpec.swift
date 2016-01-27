//
//  ClassSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

import Foundation

public class ClassSpec: TypeSpec {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Override, .Required]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Throws, .Convenience, .Override, .Required]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(b: ClassSpecBuilder) {
        super.init(builder: b as TypeSpecBuilder)
    }

    public static func builder(name: String) -> ClassSpecBuilder {
        return ClassSpecBuilder(name: name)
    }
}

public class ClassSpecBuilder: TypeSpecBuilder, Builder {
    public typealias Result = ClassSpec
    public static let defaultConstruct: Construct = .Class

    public init(name: String) {
        super.init(name: name, construct: ClassSpecBuilder.defaultConstruct)
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

    public func addModifier(modifier: Modifier) -> Self {
        guard ClassSpec.asMemberModifiers.contains(modifier) else {
            print("\(name) \(modifier.rawValue)")
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
