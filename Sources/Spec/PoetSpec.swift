//
//  PoetSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public protocol PoetSpecProtocol {
    var name: String { get }
    var construct: Construct { get }
    var modifiers: Set<Modifier> { get }
    var description: String? { get }
    var framework: String? { get }
    var imports: Set<String> { get }
}

public class PoetSpec: PoetSpecProtocol, Emitter, Importable {
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

extension PoetSpec: Equatable {}

public func ==(lhs: PoetSpec, rhs: PoetSpec) -> Bool {
    return lhs.dynamicType == rhs.dynamicType && lhs.toString() == rhs.toString()
}

extension PoetSpec: Hashable {
    public var hashValue: Int {
        return self.toString().hashValue
    }
}

public class SpecBuilder: PoetSpecProtocol {
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

    internal func addModifiers(internalModifiers modifiers: [Modifier]) {
        modifiers.forEach { addModifier(internalModifier: $0) }
    }

    internal func addDescription(internalDescription description: String?) {
        self.description = description
    }

    internal func addFramework(internalFramework framework: String?) {
        self.framework = PoetUtil.fmap(PoetUtil.cleanTypeName, a: framework)
    }

    internal func addImport(internalImport imprt: String) {
        self.imports.insert(imprt)
    }

    internal func addImports(internalImports imports: [String]) {
        imports.forEach { addImport(internalImport: $0) }
    }
}
