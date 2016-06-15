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

    @discardableResult
    public func add(method: MethodSpec) -> Self {
        super.mutatingAdd(method: method)
        return self
    }

    @discardableResult
    public func add(methods: [MethodSpec]) -> Self {
        methods.forEach { mutatingAdd(method: $0) }
        return self
    }

    @discardableResult
    public func add(field: FieldSpec) -> Self {
        super.mutatingAdd(field: field)
        return self
    }

    @discardableResult
    public func add(fields: [FieldSpec]) -> Self {
        fields.forEach { mutatingAdd(field: $0) }
        return self
    }

    @discardableResult
    public func add(protocol _protocol: TypeName) -> Self {
        super.mutatingAdd(protocol: _protocol)
        return self
    }

    @discardableResult
    public func add(protocols: [TypeName]) -> Self {
        super.mutatingAdd(protocols: protocols)
        return self
    }

    @discardableResult
    public func add(superType: TypeName) -> Self {
        super.mutatingAdd(superType: superType)
        return self
    }

    @discardableResult
    public func add(modifier: Modifier) -> Self {
        guard EnumSpec.asMemberModifiers.contains(modifier) else {
            return self
        }
        mutatingAdd(modifier: modifier)
        return self
    }

    @discardableResult
    public func add(modifiers: [Modifier]) -> Self {
        modifiers.forEach { let _ = add(modifier: $0) }
        return self
    }

    @discardableResult
    public func add(description: String?) -> Self {
        super.mutatingAdd(description: description)
        return self
    }

    @discardableResult
    public func add(framework: String?) -> Self {
        super.mutatingAdd(framework: framework)
        return self
    }

    @discardableResult
    public func add(import _import: String) -> Self {
        super.mutatingAdd(import: _import)
        return self
    }

    @discardableResult
    public func add(imports: [String]) -> Self {
        super.mutatingAdd(imports: imports)
        return self
    }
}
