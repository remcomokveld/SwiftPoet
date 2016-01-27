//
//  TypeSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol TypeSpecProtocol {
    // Class variables are not supported yet. Impliment class variables in each child class
//    class var implicitFieldModifiers: [Modifier] { get }
//    class var implicitMethodModifiers: [Modifier] { get }
//    class var implicitTypeModifiers: [Modifier] { get }
//    class var asMemberModifiers: [Modifier] { get }

    var methodSpecs: [MethodSpec] { get }
    var fieldSpecs: [FieldSpec] { get }
    var superType: TypeName? { get }
    var superProtocols: [TypeName] { get }
}

public class TypeSpec: PoetSpec, TypeSpecProtocol {
    public let methodSpecs: [MethodSpec]
    public let fieldSpecs: [FieldSpec]
    public let superType: TypeName?
    public let superProtocols: [TypeName]

    public init(builder: TypeSpecBuilder) {
        methodSpecs = builder.methodSpecs
        fieldSpecs = builder.fieldSpecs
        superType = builder.superType
        superProtocols = builder.superProtocols

        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers, description: builder.description, framework: builder.framework, imports: builder.imports)
    }

    public override func collectImports() -> Set<String> {
        let externalImports = [
            methodSpecs.reduce(Set<String>()) { set, m in
            return set.union(m.collectImports())
            },
            fieldSpecs.reduce(Set<String>()) { set, f in
                return set.union(f.collectImports())
            },
            superProtocols.reduce(Set<String>()) { set, sp in
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
        codeWriter.emitDocumentation(self)
        codeWriter.emitModifiers(modifiers)
        let cbBuilder = CodeBlock.builder()
        cbBuilder.addLiteral(construct)
        cbBuilder.addLiteral(name)
        codeWriter.emit(cbBuilder.build())
        codeWriter.emitInheritance(superType, superProtocols: superProtocols)
        codeWriter.emit(.BeginStatement)
        codeWriter.emitNewLine()

        var first = true

        fieldSpecs.forEach { spec in
            if !first { codeWriter.emitNewLine() }
            spec.emit(codeWriter)
            first = false
        }

        if !methodSpecs.isEmpty {
            codeWriter.emitNewLine()
        }

        methodSpecs.forEach { spec in
            codeWriter.emitNewLine()
            spec.emit(codeWriter)
            codeWriter.emitNewLine()
        }

        codeWriter.emit(.EndStatement)
        
        return codeWriter
    }
}

public class TypeSpecBuilder: SpecBuilder, TypeSpecProtocol {
    public private(set) var methodSpecs = [MethodSpec]()
    public private(set) var fieldSpecs = [FieldSpec]()
    public private(set) var superProtocols = [TypeName]()
    public private(set) var superType: TypeName? = nil

    public override init(name: String, construct: Construct) {
        super.init(name: PoetUtil.cleanTypeName(name), construct: construct)
    }

    internal func addMethodSpec(internalMethodSpec methodSpec: MethodSpec) {
        if !methodSpecs.contains(methodSpec) {
            self.methodSpecs.append(methodSpec)
        }
        methodSpec.parentType = self.construct
    }

    internal func addMethodSpecs(internalMethodSpecList methodSpecList: [MethodSpec]) {
        PoetUtil.addDataToList(methodSpecList, fn: addMethodSpec)
    }

    internal func addFieldSpec(internalFieldSpec fieldSpec: FieldSpec) {
        if !fieldSpecs.contains(fieldSpec) {
            self.fieldSpecs.append(fieldSpec)
            fieldSpec.parentType = self.construct
        }
    }

    internal func addFieldSpecs(internalFieldSpecList fieldSpecList: [FieldSpec]) {
        PoetUtil.addDataToList(fieldSpecList, fn: addFieldSpec)
    }

    internal func addProtocol(internalProtocolSpec protocolSpec: TypeName) {
        if !superProtocols.contains(protocolSpec) {
            superProtocols.append(protocolSpec)
        }
    }

    internal func addProtocols(internalProtocolSpecList protocolList: [TypeName]) {
        PoetUtil.addDataToList(protocolList, fn: addProtocol)
    }

    internal func addSuperType(internalSuperClass superClass: TypeName) {
        superType = superClass
    }
}
