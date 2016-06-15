//
//  ClassSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/11/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

public class ClassSpec: TypeSpec {
    public static let fieldModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Override, .Required]
    public static let methodModifiers: [Modifier] = [.Public, .Private, .Internal, .Static, .Final, .Klass, .Throws, .Convenience, .Override, .Required]
    public static let asMemberModifiers: [Modifier] = [.Public, .Private, .Internal]

    private init(builder: ClassSpecBuilder) {
        super.init(builder: builder as TypeSpecBuilder)
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
        return ClassSpec(builder: self)
    }
}

// MARK: Chaining
extension ClassSpecBuilder {

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
        guard ClassSpec.asMemberModifiers.contains(modifier) else {
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
    public func addImport(import _import: String) -> Self {
        mutatingAdd(import: _import)
        return self
    }

    @discardableResult
    public func add(imports: [String]) -> Self {
        mutatingAdd(imports: imports)
        return self
    }
}
