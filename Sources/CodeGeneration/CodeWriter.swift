//
//  CodeWriter.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/10/15.
//
//

import Foundation

public typealias Appendable = String.CharacterView

public class CodeWriter {
    private var _out: Appendable
    public var out: String {
        return String(_out)
    }

    private var indentLevel: Int

    private let documentation: Bool
    private let comment: Bool
//    private let packageName: String

    private var typeSpecStack = [String]()
    private var importableTypes = [String : String]()
    private var referenceNames = [String]()
    private let trailingNewLine: Bool
    private var _importedTypes: [String : String]

    public var importedTypes: [String: String] {
        return _importedTypes
    }

//    private var statementLine: Int = -1

    public convenience init(out: Appendable = Appendable("")) {
        self.init(out: out, indentLevel: 0)
    }

    public convenience init(out: Appendable, indentLevel: Int) {
        self.init(out: out, indentLevel: indentLevel, importedTypes: [String : String]())
    }

    public init(out: Appendable, indentLevel: Int, importedTypes: [String : String]) {
        self._out = out
        self.indentLevel = indentLevel
        self._importedTypes = importedTypes

        documentation = false
        comment = false
        trailingNewLine = true
    }

    public func pushType(type: String) -> CodeWriter {
        typeSpecStack.append(type)
        return self
    }

    public func popType() -> CodeWriter {
        typeSpecStack.popLast()
        return self
    }
}

// MARK: Indentation
public extension CodeWriter {
    public func indent() -> CodeWriter {
        return indent(1)
    }

    public func indent(levels: Int) -> CodeWriter {
        return indentLevels(levels)
    }

    public func unindent() -> CodeWriter {
        return unindent(1)
    }

    public func unindent(levels: Int) -> CodeWriter {
        return indentLevels(-levels)
    }

    private func indentLevels(levels: Int) -> CodeWriter {
        indentLevel = max(indentLevel + levels, 0)
        return self
    }
}

extension CodeWriter {
    public func emitDocumentation(o: AnyObject) {
        if let spec = o as? TypeSpecImpl, let docs = spec.description {
            var specDoc = "" as String

            let firstline = String.indent("/**\n", i: indentLevel)
            let lastline = String.indent("*/\n", i: indentLevel)
            let indentedDocs = String.indent(docs + "\n", i: indentLevel + 1)

            specDoc.appendContentsOf(firstline)
            specDoc.appendContentsOf(indentedDocs)
            specDoc.appendContentsOf(lastline)
            _out.appendContentsOf(specDoc.characters)
        } else if let spec = o as? FieldSpec, let docs = spec.description {
            let comment = String.indent("// \(docs)\n", i: indentLevel)
            _out.appendContentsOf(comment.characters)
        } else if let spec = o as? MethodSpec {
            guard spec.description != nil || spec.parameters.count > 0 else {
                return
            }

            var specDoc = "" as String

            let firstline = String.indent("/**\n", i: indentLevel)
            let lastline = String.indent("*/\n", i: indentLevel)
            let indentedDocs = PoetUtil.fmap({ String.indent($0 + "\n", i: self.indentLevel + 1) }, a: spec.description)

            specDoc.appendContentsOf(firstline)
            if indentedDocs != nil {
                specDoc.appendContentsOf(indentedDocs!)
            }

            var first = true
            spec.parameters.forEach { p in
                if first && spec.description != nil {
                    specDoc.appendContentsOf("\n")
                } else if !first {
                    specDoc.appendContentsOf("\n\n")
                }
                first = false

                var paramDoc = ":param:    \(p.name)"
                if let desc = p.description {
                    paramDoc.appendContentsOf(" \(desc)")
                }
                specDoc.appendContentsOf(String.indent(paramDoc, i: indentLevel + 1))
            }
            specDoc.appendContentsOf("\n")
            specDoc.appendContentsOf(lastline)
            _out.appendContentsOf(specDoc.characters)
        }
    }

    public func emitModifiers(modifiers: Set<Modifier>) {
        var first = true
        let modListStr = modifiers.reduce("") { accum, mod in
            let modStr = first ? mod.rawValue : " " + mod.rawValue
            first = false
            return accum + modStr
        }

        _out.appendContentsOf(String.indent(modListStr, i: indentLevel).characters)
    }

    public func emit(codeBlock: CodeBlock) -> CodeWriter {
        var first = true
        codeBlock.emittableObjects.forEach { either in
            switch either {
            case .Right(let cb):
                self.emitNewLine()
                self.emitWithIndentation(cb)
            case .Left(let emitObject):
                switch emitObject.type {
                case .Literal:
                    self.emitLiteral(emitObject.any, first: first)
                case .BeginStatement:
                    self.emitBeginStatement()
                case .EndStatement:
                    self.emitEndStatement()
                case .EscapedString:
                    let str = emitObject.any ?? ""
                    self.emitLiteral("\"\(str)\"", first: first)
                case .Emitter:
                    self.emitEmitter(emitObject.any, first: first)
                default:
                    break
                }
                first = false
            }
        }
        return self
    }

    public func emit(type: EmitType, any: Any? = nil) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        cbBuilder.addEmitObject(type, any: any)
        return self.emit(cbBuilder.build())
    }

    private func emitLiteral(o: Any?, first: Bool = false) {
        if let _ = o as? TypeSpecImpl {
            // Dunno
        } else if let literalType = o as? Literal {
            var lv = literalType.literalValue().characters
            if !first { lv.insert(" ", atIndex: lv.startIndex) }
            _out.appendContentsOf(lv)
        } else if let str = o as? String {
            _out.appendContentsOf(str.characters)
        }
    }

    private func emitEmitter(o: Any?, first: Bool) {
        if let emitter = o as? Emitter {
            if !first { _out.append(" ") }
            emitter.emit(self)
        }
    }

    public func emitInheritance(superType: TypeName?, superProtocols: [TypeName]?) -> CodeWriter {
        var inheritance = ": "
        if let st = superType {
            inheritance += st.literalValue()
            if let sp = superProtocols where sp.count > 0 {
                inheritance += ", "
                inheritance = emitProtocolInheritnace(superProtocols, output: inheritance)
            }
            _out.appendContentsOf(inheritance.characters)
        } else if let sp = superProtocols where sp.count > 0 {
            inheritance = emitProtocolInheritnace(superProtocols, output: inheritance)
            _out.appendContentsOf(inheritance.characters)

        }

        return self
    }

    private func emitProtocolInheritnace(superProtocols: [TypeName]?, var output: String) -> String {
        if let sp = superProtocols {
            sp.forEach { protocolType in
                var literal = protocolType.literalValue()
                let spacer = ", ".characters
                literal.insertContentsOf(spacer, at: literal.endIndex)
                output += literal
            }
            output.removeRange(Range(start: output.endIndex.predecessor().predecessor(), end: output.endIndex))
        }
        return output
    }

    private func emitBeginStatement() {
        let begin = " {\n"
        _out.appendContentsOf(begin.characters)
        indent()
    }

    private func emitEndStatement() {
        let newline = "\n"
        unindent()
        let endBracket = String.indent("}\n", i: indentLevel)
        let end = newline + endBracket
        _out.appendContentsOf(end.characters)
    }

    public func emitNewLine() {
        _out.append("\n")
    }

    public func emitWithIndentation(cb: CodeBlock) {
        let indentation = String.indent("", i: indentLevel)
        _out.appendContentsOf(indentation.characters)
        emit(cb)
    }
}

extension String {
    private static let indentSpacing = ("    ").characters

    private static func indent(var s: String, i: Int) -> String {
        i.times {
            s.insertContentsOf(String.indentSpacing, at: s.startIndex)
        }
        return s
    }
}

extension Int {
    private func times(fn: () -> Void) {
        for var index = 0; index < self; index++ {
            fn()
        }
    }
}

