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

    func toString() -> String
}

public class PoetSpecImpl: PoetSpec, Emitter {
    public let name: String
    public let construct: Construct
    public let modifiers: Set<Modifier>
    public let description: String?

    public init(name: String, construct: Construct, modifiers: Set<Modifier>, description: String?) {
        self.name = name
        self.construct = construct
        self.modifiers = modifiers
        self.description = description
    }

    public func emit(codeWriter: CodeWriter) -> CodeWriter {
        fatalError("Override emit method in child")
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
}

public class SpecBuilderImpl: SpecBuilder {
    public let name: String
    public let construct: Construct

    private var _description: String? = nil
    public var description: String? {
        return _description
    }

    private var _modifiers = Set<Modifier>()
    public var modifiers: Set<Modifier> {
        return _modifiers
    }

    public init(name: String, construct: Construct) {
        self.name = name // clean the string in child
        self.construct = construct
    }

    internal func addModifier(internalMethod m: Modifier) {
        if !(_modifiers.contains(m)) {
            _modifiers.insert(m)
        }
    }

    internal func addModifiers(modifiers mList: [Modifier]) {
        mList.forEach { addModifier(internalMethod: $0) }
    }

    internal func addDescription(description: String?) {
        self._description = description
    }
}
