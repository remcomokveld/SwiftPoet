//
//  TypeSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol TypeSpec {
    // Class variables are not supported yet. Impliment class variables in each child class
//    class var implicitFieldModifiers: [Modifier] { get }
//    class var implicitMethodModifiers: [Modifier] { get }
//    class var implicitTypeModifiers: [Modifier] { get }
//    class var asMemberModifiers: [Modifier] { get }

    var methodSpecs: [MethodSpec]? { get }
    var fieldSpecs: [FieldSpec]? { get }
    var superType: TypeName? { get }
    var superProtocols: [TypeName]? { get }
}

public class TypeSpecImpl: PoetSpecImpl, TypeSpec {
    public let methodSpecs: [MethodSpec]?
    public let fieldSpecs: [FieldSpec]?
    public let superType: TypeName?
    public let superProtocols: [TypeName]?

    public init(builder: TypeSpecBuilderImpl) {
        methodSpecs = builder.methodSpecs
        fieldSpecs = builder.fieldSpecs
        superType = builder.superType
        superProtocols = builder.superProtocols

        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers, description: builder.description, framework: builder.framework, imports: builder.imports)
    }

    public override func collectImports() -> Set<String> {
        let externalImports = [
            methodSpecs?.reduce(Set<String>()) { set, m in
            return set.union(m.collectImports())
            },
            fieldSpecs?.reduce(Set<String>()) { set, f in
                return set.union(f.collectImports())
            },
            superProtocols?.reduce(Set<String>()) { set, sp in
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

        fieldSpecs?.forEach { spec in
            if !first { codeWriter.emitNewLine() }
            spec.emit(codeWriter)
            first = false
        }

        if (methodSpecs?.count > 0) {
            codeWriter.emitNewLine()
        }

        methodSpecs?.forEach { spec in
            codeWriter.emitNewLine()
            spec.emit(codeWriter)
            codeWriter.emitNewLine()
        }

        codeWriter.emit(.EndStatement)
        
        return codeWriter
    }
}

public protocol TypeSpecBuilder {
    var methodSpecs: [MethodSpec]? { get }
    var fieldSpecs: [FieldSpec]? { get }
    var superType: TypeName? { get }
    var superProtocols: [TypeName]? { get }
}

public class TypeSpecBuilderImpl: SpecBuilderImpl, TypeSpecBuilder {
    public private(set) var methodSpecs: [MethodSpec]?
    public private(set) var fieldSpecs: [FieldSpec]?
    public private(set) var superProtocols: [TypeName]?
    public private(set) var superType: TypeName?

    internal init(name: String, construct: Construct, methodSpecs ms: [MethodSpec]?, fieldSpecs fs: [FieldSpec]?, superProtocols ps: [TypeName]?) {
        self.methodSpecs = ms
        self.fieldSpecs = fs
        self.superProtocols = ps

        super.init(name: PoetUtil.cleanTypeName(name), construct: construct)
    }

    internal func addMethodSpecs(methodSpecList: [MethodSpec]) {
        PoetUtil.addDataToList(methodSpecList, fn: addMethodSpec)
    }

    internal func addMethodSpec(methodSpec ms: MethodSpec) {
        guard let mSpecs = methodSpecs else { return }

        if (mSpecs.filter { $0 == ms }).count == 0 {
            methodSpecs?.append(ms)
        }
    }

    internal func addFieldSpec(fieldSpec: FieldSpec) {
        guard let fs = fieldSpecs else { return }

        if (fs.filter { $0 == fieldSpec }).count == 0 {
            fieldSpecs?.append(fieldSpec)
            fieldSpec.parentType = self.construct
        }
    }

    internal func addFieldSpecs(fieldSpecList: [FieldSpec]) {
        PoetUtil.addDataToList(fieldSpecList, fn: addFieldSpec)
    }

    internal func addProtocol(protocolSpec: TypeName) {
        guard let ps = superProtocols else { return }

        if (ps.filter { $0 == protocolSpec }).count == 0 {
            superProtocols?.append(protocolSpec)
        }
    }

    internal func addProtocols(protocolList: [TypeName]) {
        PoetUtil.addDataToList(protocolList, fn: addProtocol)
    }

    internal func addSuperType(superClass: TypeName) {
        superType = superClass
    }
}
