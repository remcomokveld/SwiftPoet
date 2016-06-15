//
//  TypeSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol TypeSpecProtocol {
    var methods: [MethodSpec] { get }
    var fields: [FieldSpec] { get }
    var superType: TypeName? { get }
    var protocols: [TypeName] { get }
}

public class TypeSpec: PoetSpec, TypeSpecProtocol {
    public let methods: [MethodSpec]
    public let fields: [FieldSpec]
    public let superType: TypeName?
    public let protocols: [TypeName]

    public init(builder: TypeSpecBuilder) {
        methods = builder.methods
        fields = builder.fields
        superType = builder.superType
        protocols = builder.protocols

        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers, description: builder.description, framework: builder.framework, imports: builder.imports)
    }

    public override func collectImports() -> Set<String> {
        let externalImports = [
            methods.reduce(Set<String>()) { set, m in
            return set.union(m.collectImports())
            },
            fields.reduce(Set<String>()) { set, f in
                return set.union(f.collectImports())
            },
            protocols.reduce(Set<String>()) { set, sp in
                set.union(sp.collectImports())
            },
            superType?.collectImports()]

        return externalImports.reduce(imports) { set, list in
            guard let list = list else {
                return set
            }
            return set.union(list)
        }
    }

    public override func emit(codeWriter: CodeWriter) -> CodeWriter {
        codeWriter.emitDocumentation(forType: self)
        codeWriter.emitModifiers(modifiers: modifiers)
        let cbBuilder = CodeBlock.builder()
        cbBuilder.addLiteral(any: construct)
        cbBuilder.addLiteral(any: name)
        codeWriter.emit(codeBlock: cbBuilder.build())
        codeWriter.emitInheritance(superType: superType, protocols: protocols)
        codeWriter.emit(type: .BeginStatement)
        codeWriter.emitNewLine()

        var first = true

        fields.forEach { spec in
            if !first { codeWriter.emitNewLine() }
            spec.emit(codeWriter: codeWriter)
            first = false
        }

        if !methods.isEmpty {
            codeWriter.emitNewLine()
        }

        methods.forEach { spec in
            codeWriter.emitNewLine()
            spec.emit(codeWriter: codeWriter)
            codeWriter.emitNewLine()
        }

        codeWriter.emit(type: .EndStatement)
        
        return codeWriter
    }
}

public class TypeSpecBuilder: PoetSpecBuilder, TypeSpecProtocol {
    public private(set) var methods = [MethodSpec]()
    public private(set) var fields = [FieldSpec]()
    public private(set) var protocols = [TypeName]()
    public private(set) var superType: TypeName? = nil

    public override init(name: String, construct: Construct) {
        super.init(name: name.cleaned(case: .TypeName), construct: construct)
    }

    internal func mutatingAdd(method: MethodSpec) {
        if !methods.contains(method) {
            self.methods.append(method)
            method.parentType = self.construct
        }
    }

    internal func mutatingAdd(methods: [MethodSpec]) {
        for method in methods {
            mutatingAdd(method: method)
        }
    }

    internal func mutatingAdd(field: FieldSpec) {
        if !fields.contains(field) {
            self.fields.append(field)
            field.parentType = self.construct
        }
    }

    internal func mutatingAdd(fields: [FieldSpec]) {
        for field in fields {
            mutatingAdd(field: field)
        }
    }

    internal func mutatingAdd(protocol _protocol: TypeName) {
        if !protocols.contains(_protocol) {
            protocols.append(_protocol)
        }
    }

    internal func mutatingAdd(protocols: [TypeName]) {
        for _protocol in protocols {
            mutatingAdd(protocol: _protocol)
        }
    }

    internal func mutatingAdd(superType: TypeName) {
        self.superType = superType
    }
}
