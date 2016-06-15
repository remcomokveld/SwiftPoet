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

    private init(builder: StructSpecBuilder) {
        super.init(builder: builder as TypeSpecBuilder)
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
        if !(methods.contains { $0.name == "init" }) || includeInit {
            addInitMethod()
        }
        return StructSpec(builder: self)
    }

    @discardableResult
    private func addInitMethod() -> Self {
        var mb = MethodSpec.builder(name: "init")
        let cb = CodeBlock.builder()

        fields.forEach { spec in

            if Modifier.equivalentAccessLevel(parentModifiers: modifiers, childModifiers: spec.modifiers)
                && !spec.modifiers.contains(.Static) {

                mb.add(parameter: ParameterSpec.builder(name: spec.name, type: spec.type!)
                    .add(modifiers: Array(spec.modifiers))
                    .add(description: spec.description)
                    .build()
                )

                cb.addCodeBlock(codeBlock: "self.\(spec.name) = \(spec.name)".toCodeBlock())
            }
        }

        mb.add(codeBlock: cb.build())

        mb = mb.add(modifier: Modifier.accessLevel(modifiers: self.modifiers))

        return add(method: mb.build())
    }

    @discardableResult
    public func includeDefaultInit() -> StructSpecBuilder {
        includeInit = true
        return self;
    }
}

// MARK: Chaining
extension StructSpecBuilder {

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
        guard StructSpec.asMemberModifiers.contains(modifier) else {
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
