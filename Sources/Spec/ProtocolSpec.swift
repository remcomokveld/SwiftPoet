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

    private init(builder: ProtocolSpecBuilder) {
        super.init(builder: builder as TypeSpecBuilder)
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
        return ProtocolSpec(builder: self)
    }
}

// MARK: Chaining
extension ProtocolSpecBuilder {

    @discardableResult
    public func add(method: MethodSpec) -> Self {
        mutatingAdd(method: method)
        return self
    }

    @discardableResult
    public func add(methods: [MethodSpec]) -> Self {
        methods.forEach { mutatingAdd(method: $0) }
        return self
    }

    @discardableResult
    public func add(field: FieldSpec) -> Self {
        mutatingAdd(field: field)
        return self
    }

    @discardableResult
    public func add(fields: [FieldSpec]) -> Self {
        fields.forEach { mutatingAdd(field: $0) }
        return self
    }

    @discardableResult
    public func add(protocol _protocol: TypeName) -> Self {
        mutatingAdd(protocol: _protocol)
        return self
    }

    @discardableResult
    public func add(protocols: [TypeName]) -> Self {
        mutatingAdd(protocols: protocols)
        return self
    }

    @discardableResult
    public func add(superType: TypeName) -> Self {
        mutatingAdd(superType: superType)
        return self
    }

    @discardableResult
    public func add(modifier: Modifier) -> Self {
        guard ProtocolSpec.asMemberModifiers.contains(modifier) else {
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
        mutatingAdd(description: description)
        return self
    }

    @discardableResult
    public func add(framework: String?) -> Self {
        mutatingAdd(framework: framework)
        return self
    }

    @discardableResult
    public func add(import _import: String) -> Self {
        mutatingAdd(import: _import)
        return self
    }

    @discardableResult
    public func add(imports: [String]) -> Self {
        mutatingAdd(imports: imports)
        return self
    }
}
