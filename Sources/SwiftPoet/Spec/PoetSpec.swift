//
//  PoetSpec.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//


import Foundation

@objc public protocol PoetSpecType {
    var name: String { get }
    var construct: Construct { get }
    var modifiers: Set<Modifier> { get }
    var description: String? { get }
    var framework: String? { get }
    var imports: Set<String> { get }
}

public class PoetSpec: PoetSpecType, Emitter, Importable {
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

    public func toString() -> String {
        return emit(codeWriter: CodeWriter()).out
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

public class PoetSpecBuilder: PoetSpecType {
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

    internal func mutatingAdd(modifier: Modifier) {
        modifiers.insert(modifier)
    }

    internal func mutatingAdd(modifiers: [Modifier]) {
        modifiers.forEach { mutatingAdd(modifier: $0) }
    }

    internal func mutatingAdd(description: String?) {
        self.description = description
    }

    internal func mutatingAdd(framework: String?) {
        self.framework = framework?.cleaned(case: .TypeName)
    }

    internal func mutatingAdd(import _import: String) {
        self.imports.insert(_import)
    }

    internal func mutatingAdd(imports: [String]) {
        imports.forEach { mutatingAdd(import: $0) }
    }
}
