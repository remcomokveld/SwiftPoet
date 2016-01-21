//
//  ControlFlow.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/18/15.
//
//

import Foundation

public enum ControlFlow: String {
    case Guard = "guard"
//    case GuardWhere
    case If = "if"
    case ElseIf = "else if"
    case Else = "else"
    case While = "while"
    case RepeatWhile = "repeat"
    case ForIn = "in"
    case For = "for"
    case Switch = "switch"

    public static var guardControlFlow: (CodeBlock, ComparisonList?) -> CodeBlock = ControlFlow.fnGenerator(.Guard)

    public static var ifControlFlow: (CodeBlock, ComparisonList?) -> CodeBlock = ControlFlow.fnGenerator(.If)

    public static var elseIfControlFlow: (CodeBlock, ComparisonList?) -> CodeBlock = ControlFlow.fnGenerator(.ElseIf)

    public static var elseControlFlow: (CodeBlock, ComparisonList?) -> CodeBlock = ControlFlow.fnGenerator(.Else)

    public static var whileControlFlow: (CodeBlock, ComparisonList?) -> CodeBlock = ControlFlow.fnGenerator(.While)

    public static func repeatWhileControlFlow(codeBlock: CodeBlock, comparisonList: ComparisonList) -> CodeBlock {
        let cb = CodeBlock.builder()
        cb.addEmitObject(.Literal, any: ControlFlow.RepeatWhile.rawValue)
        cb.addEmitObject(.BeginStatement)
        cb.addCodeBlock(codeBlock)
        cb.addEmitObject(.EndStatement)
        cb.addEmitObject(.Literal, any: ControlFlow.While.rawValue)
        cb.addEmitObject(.Emitter, any: comparisonList)
        return cb.build()
    }

    public static func forInControlFlow(iterator: CodeBlock, iterable: CodeBlock, execution: CodeBlock) -> CodeBlock {
        let cb = CodeBlock.builder()
        cb.addEmitObject(.Literal, any: ControlFlow.For.rawValue)
        cb.addEmitObjects(iterator.emittableObjects)
        cb.addEmitObject(.Literal, any: ControlFlow.ForIn.rawValue)
        cb.addEmitObjects(iterator.emittableObjects)
        cb.addEmitObject(.BeginStatement)
        cb.addCodeBlock(execution)
        cb.addEmitObject(.EndStatement)
        return cb.build()
    }

    public static func closureControlFlow(parameters: CodeBlock, canThrow: Bool, returnType: CodeBlock? , execution: CodeBlock) -> CodeBlock {
        let cb = CodeBlock.builder()
        let closureBlock = CodeBlock.builder()

        cb.addEmitObject(.BeginStatement)

        closureBlock.addEmitObject(.Literal, any: "(")
        closureBlock.addEmitObjects(parameters.emittableObjects)
        closureBlock.addEmitObject(.Literal, any: ")")
        if canThrow {
            closureBlock.addEmitObject(.Literal, any: "throws")
        }
        closureBlock.addEmitObject(.Literal, any: "->")
        if returnType != nil {
            closureBlock.addEmitObjects(returnType!.emittableObjects)
        } else {
            closureBlock.addEmitObject(.Literal, any: "void")
        }
        closureBlock.addEmitObject(.Literal, any: ControlFlow.ForIn.rawValue)
        closureBlock.addEmitObject(.IncreaseIndentation)
        closureBlock.addCodeBlock(execution)
        closureBlock.addEmitObject(.DecreaseIndentation)

        cb.addCodeBlock(closureBlock.build())
        cb.addEmitObject(.EndStatement)

        return cb.build()
    }

    public static func forControlFlow(iterator: CodeBlock, iterable: CodeBlock, execution: CodeBlock) -> CodeBlock {
        fatalError("So many loops so little time")
    }

    public static func switchControlFlow(switchValue: String, cases: [(String, CodeBlock)], defaultCase: CodeBlock? = nil) -> CodeBlock {
        let cb = CodeBlock.builder()
        cb.addEmitObject(.Literal, any: ControlFlow.Switch.rawValue)
        cb.addEmitObject(.Literal, any: switchValue)
        cb.addEmitObject(.BeginStatement)

        cases.forEach { caseItem in
            cb.addCodeBlock(ControlFlow.switchCase(caseItem.0, execution: caseItem.1))
        }

        if let defaultCase = defaultCase {
            cb.addCodeBlock(ControlFlow.switchCase(nil, execution: defaultCase))
        }

        cb.addEmitObject(.EndStatement)
        return cb.build()
    }

    private static func switchCase(caseLine: String?, execution: CodeBlock) -> CodeBlock {
        let caseWord = caseLine == nil ? "default" : "case"
        let cbCase = CodeBlock.builder()
        let cbCaseLineTwo = CodeBlock.builder()

        cbCase.addEmitObject(.Literal, any: caseWord)
        cbCase.addEmitObject(.Literal, any: caseLine)
        cbCase.addEmitObject(.Literal, any: ":")

        cbCaseLineTwo.addEmitObject(.IncreaseIndentation)
        cbCaseLineTwo.addCodeBlock(execution)
        cbCaseLineTwo.addEmitObject(.DecreaseIndentation)

        cbCase.addCodeBlock(cbCaseLineTwo.build())

        return cbCase.build()
    }

    private static func fnGenerator(type: ControlFlow) -> (CodeBlock, ComparisonList?) -> CodeBlock {
        return { (codeBlock: CodeBlock, comparisonList: ComparisonList?) -> CodeBlock in
            let cb = CodeBlock.builder()
            cb.addEmitObject(.Literal, any: type.rawValue)

            if type != .Else && comparisonList != nil {
                cb.addEmitObject(.Emitter, any: comparisonList!)
            }

            if type == .Guard {
                cb.addEmitObject(.Literal, any: "else")
            }

            cb.addEmitObject(.BeginStatement)
            cb.addCodeBlock(codeBlock)
            cb.addEmitObject(.EndStatement)
            return cb.build()
        }
    }
}

public struct ComparisonList: Emitter {
    private let requirement: Requirement?
    private let list: [Either<ComparisonListItem, ComparisonList>]

    public init(lhs: CodeBlock, comparator: Comparator, rhs: CodeBlock) {
        let comparison = Comparison(lhs: lhs, comparator: comparator, rhs: rhs)
        let listItem = ComparisonListItem(comparison: comparison)
        self.list = [Either.Left(listItem)]
        self.requirement = nil
    }

    public init(list: [ComparisonListItem], requirement: Requirement? = nil) {
        self.list = list.map { item in
            return Either.Left(item)
        }
        self.requirement = requirement
    }

    public init(list: [Either<ComparisonListItem, ComparisonList>], requirement: Requirement? = nil) {
        self.list = list
        self.requirement = requirement
    }

    public func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        if requirement != nil {
            codeWriter.emit(.Literal, any: requirement!)
        }

        list.forEach { listItem in
            switch listItem {
            case .Left(let item):
                item.emit(codeWriter)
            case .Right(let cList):
                codeWriter.emit(.Literal, any: "(")
                cList.emit(codeWriter)
                codeWriter.emit(.Literal, any: ")")
            }
        }

        return codeWriter
    }
}

public struct ComparisonListItem: Emitter {
    let comparison: Comparison
    let requirement: Requirement?

    public init(comparison: Comparison, requirement: Requirement? = nil) {
        self.comparison = comparison
        self.requirement = requirement
    }

    public func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        if requirement != nil {
            codeWriter.emit(.Literal, any: requirement!.rawValue)
        }
        return comparison.emit(codeWriter)
    }
}

public struct Comparison: Emitter {
    let lhs: CodeBlock
    let comparator: Comparator
    let rhs: CodeBlock

    public init(lhs: CodeBlock, comparator: Comparator, rhs: CodeBlock) {
        self.lhs = lhs
        self.comparator = comparator
        self.rhs = rhs
    }

    public func emit(codeWriter: CodeWriter, asFile: Bool = false) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        cbBuilder.addEmitObjects(lhs.emittableObjects)
        cbBuilder.addEmitObject(.Literal, any: comparator.rawValue)
        cbBuilder.addEmitObjects(rhs.emittableObjects)
        codeWriter.emit(cbBuilder.build())

        return codeWriter
    }
}

public enum Comparator: String {
    case Equals = "=="
    case NotEquals = "!="
    case LessThan = "<"
    case GreaterThan = ">"
    case LessThanOrEqualTo = "<="
    case GreaterThanOrEqualTo = ">="
    case OptionalCheck = "="
}

public enum Requirement: String {
    case And = "&&"
    case Or = "||"
    case OptionalList = ", "
}
