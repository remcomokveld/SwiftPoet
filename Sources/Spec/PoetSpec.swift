//
//  PoetSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol PoetSpec {
    var name: String { get }
    var construct: Construct { get }
    var modifiers: Set<Modifier> { get }
    var description: String? { get }
    var framework: String? { get }
    var imports: Set<String> { get }

    func toString() -> String
    func collectImports() -> Set<String>
    func toFile() -> PoetFile
}

public class PoetSpecImpl: PoetSpec, Emitter, Importable {
    public let name: String
    public let construct: Construct
    public let modifiers: Set<Modifier>
    public let description: String?
    public let framework: String?
    public let imports: Set<String>

    public init(name: String, construct: Construct, modifiers: Set<Modifier>, description: String?, framework: String?, imports: Set<String>) {
        self.name = name
        self.construct = construct
        self.modifiers = modifiers
        self.description = description
        self.framework = framework
        self.imports = imports
    }

    public func emit(codeWriter: CodeWriter) -> CodeWriter {
        fatalError("Override emit method in child")
    }

    public func collectImports() -> Set<String> {
        fatalError("Override collectImports method in child")
    }

    public func toFile() -> PoetFile {
        return PoetFile(spec: self, framework: framework)
    }
}

extension PoetSpecImpl: Equatable {}

public func ==(lhs: PoetSpecImpl, rhs: PoetSpecImpl) -> Bool {
    return lhs.dynamicType == rhs.dynamicType && lhs.toString() == rhs.toString()
}

extension PoetSpecImpl: Hashable {
    public var hashValue: Int {
        return self.toString().hashValue
    }
}

public protocol SpecBuilder {
    var name: String { get }
    var construct: Construct { get }
    var modifiers: Set<Modifier> { get }
    var description: String? { get }
    var framework: String? { get }
    var imports: Set<String> { get }
}

public class SpecBuilderImpl: SpecBuilder {
    public let name: String
    public let construct: Construct
    public private(set) var modifiers = Set<Modifier>()
    public private(set) var description: String? = nil
    public private(set) var framework: String? = nil
    public private(set) var imports = Set<String>()

    public init(name: String, construct: Construct) {
        self.name = name // clean the string in child
        self.construct = construct
    }

    internal func addModifier(internalModifier modifier: Modifier) {
        self.modifiers.insert(modifier)
    }

    internal func addModifiers(modifiers: [Modifier]) {
        modifiers.forEach { addModifier(internalModifier: $0) }
    }

    internal func addDescription(description: String?) {
        self.description = description
    }

    internal func addFramework(internalFramework framework: String?) {
        self.framework = PoetUtil.fmap(PoetUtil.cleanTypeName, a: framework)
    }

    internal func addImport(imprt: String) {
        self.imports.insert(imprt)
    }

    internal func addImports(imports: [String]) {
        imports.forEach { addImport($0) }
    }
}
