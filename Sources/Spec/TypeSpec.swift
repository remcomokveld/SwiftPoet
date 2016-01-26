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

        super.init(name: builder.name, construct: builder.construct, modifiers: builder.modifiers, description: builder.description, imports: builder.imports)
    }

    public override func collectImports() -> Set<String> {
        var collectedImports = Array(arrayLiteral: imports)
        methodSpecs?.forEach { collectedImports.append($0.collectImports()) }
        fieldSpecs?.forEach { collectedImports.append($0.collectImports()) }
        superProtocols?.forEach { collectedImports.append($0.collectImports()) }

        if let superType = superType {
            collectedImports.append(superType.collectImports())
        }

        return collectedImports.reduce(Set<String>()) { (var dict, set) in
            set.forEach { dict.insert($0) }
            return dict
        }
    }

    public override func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        if asFile {
            codeWriter.emitFileHeader(self)
            let imports = collectImports()
            codeWriter.emitImports(imports)
        }
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

        if asFile {
            codeWriter.emitNewLine()
        }
        
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
    public var _methodSpecs: [MethodSpec]?
    public var methodSpecs: [MethodSpec]? {
        return _methodSpecs
    }

    public var _fieldSpecs: [FieldSpec]?
    public var fieldSpecs: [FieldSpec]? {
        return _fieldSpecs
    }

    public var _superProtocols: [TypeName]?
    public var superProtocols: [TypeName]? {
        return _superProtocols
    }

    public var _superType: TypeName? = nil
    public var superType: TypeName? {
        return _superType
    }

    internal init(name: String, construct: Construct, methodSpecs ms: [MethodSpec]?, fieldSpecs fs: [FieldSpec]?, superProtocols ps: [TypeName]?) {
        self._methodSpecs = ms
        self._fieldSpecs = fs
        self._superProtocols = ps

        super.init(name: PoetUtil.cleanTypeName(name), construct: construct)
    }

    internal func addMethodSpecs(methodSpecList: [MethodSpec]) {
        PoetUtil.addDataToList(methodSpecList, fn: addMethodSpec)
    }

    internal func addMethodSpec(methodSpec ms: MethodSpec) {
        guard let mSpecs = _methodSpecs else { return }

        if (mSpecs.filter { $0 == ms }).count == 0 {
            _methodSpecs?.append(ms)
        }
    }

    internal func addFieldSpec(fieldSpec: FieldSpec) {
        guard let fs = _fieldSpecs else { return }

        if (fs.filter { $0 == fieldSpec }).count == 0 {
            _fieldSpecs?.append(fieldSpec)
            fieldSpec.parentType = self.construct
        }
    }

    internal func addFieldSpecs(fieldSpecList: [FieldSpec]) {
        PoetUtil.addDataToList(fieldSpecList, fn: addFieldSpec)
    }

    internal func addProtocol(protocolSpec: TypeName) {
        guard let ps = _superProtocols else { return }

        if (ps.filter { $0 == protocolSpec }).count == 0 {
            _superProtocols?.append(protocolSpec)
        }
    }

    internal func addProtocols(protocolList: [TypeName]) {
        PoetUtil.addDataToList(protocolList, fn: addProtocol)
    }

    internal func addSuperType(superClass: TypeName) {
        _superType = superClass
    }
}
