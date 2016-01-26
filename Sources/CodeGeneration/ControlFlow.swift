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

    public static var guardControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(.Guard)

    public static var ifControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(.If)

    public static var elseIfControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(.ElseIf)

    public static var elseControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(.Else)

    public static var whileControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(.While)

    public static func repeatWhileControlFlow(comparisonList: ComparisonList, bodyFn: () -> CodeBlock) -> CodeBlock {
        return CodeBlock.builder()
            .addLiteral(ControlFlow.RepeatWhile.rawValue)
            .addEmitObject(.BeginStatement)
            .addCodeBlock(bodyFn())
            .addEmitObject(.EndStatement)
            .addLiteral(ControlFlow.While.rawValue)
            .addEmitObject(.Emitter, any: comparisonList)
            .build()
    }

    public static func forInControlFlow(iterator: Literal, iterable: Literal, bodyFn: () -> CodeBlock) -> CodeBlock {
        return CodeBlock.builder()
            .addLiteral(ControlFlow.For.rawValue)
            .addLiteral(iterator)
            .addEmitObject(.Literal, any: ControlFlow.ForIn.rawValue)
            .addLiteral(iterator)
            .addEmitObject(.BeginStatement)
            .addCodeBlock(bodyFn())
            .addEmitObject(.EndStatement)
            .build()
    }

    public static func closureControlFlow(parameterBlock: Literal, canThrow: Bool, returnType: Literal? , bodyFn: () -> CodeBlock) -> CodeBlock {
        let cb = CodeBlock.builder()
        let closureBlock = CodeBlock.builder()

        cb.addEmitObject(.BeginStatement)

        closureBlock.addLiteral("(")
        closureBlock.addLiteral(parameterBlock)
        closureBlock.addLiteral(")")
        if canThrow {
            closureBlock.addLiteral("throws")
        }
        closureBlock.addLiteral("->")
        if let returnType = returnType {
            closureBlock.addLiteral(returnType)
        } else {
            closureBlock.addLiteral("Void")
        }
        closureBlock.addLiteral(ControlFlow.ForIn.rawValue)

        closureBlock.addEmitObject(.IncreaseIndentation)
        closureBlock.addCodeBlock(bodyFn())
        closureBlock.addEmitObject(.DecreaseIndentation)

        cb.addCodeBlock(closureBlock.build())
        cb.addEmitObject(.EndStatement)

        return cb.build()
    }

    public static func forControlFlow(iterator: CodeBlock, iterable: CodeBlock, execution: CodeBlock) -> CodeBlock {
        fatalError("So many loops so little time")
    }

    public static func doCatchControlFlow(doFn: () -> CodeBlock, catchFn: () -> CodeBlock) -> CodeBlock {
        let doCB = CodeBlock.builder()
        doCB.addLiteral("do")
        doCB.addEmitObject(.BeginStatement)
        doCB.addCodeBlock(doFn())
        doCB.addEmitObject(.EndStatement)

        let catchCB = CodeBlock.builder()
        catchCB.addLiteral("catch")
        catchCB.addEmitObject(.BeginStatement)
        catchCB.addCodeBlock(catchFn())
        catchCB.addEmitObject(.EndStatement)

        return doCB.addCodeBlock(catchCB.build()).build()
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

    private static func fnGenerator(type: ControlFlow) -> (ComparisonList?, () -> CodeBlock) -> CodeBlock {
        return { (comparisonList: ComparisonList?, bodyFn: () -> CodeBlock) -> CodeBlock in
            let cb = CodeBlock.builder()
                .addLiteral(type.rawValue)

            if type != .Else && comparisonList != nil {
                cb.addEmitObject(.Emitter, any: comparisonList!)
            }

            if type == .Guard {
                cb.addLiteral("else")
            }

            cb.addEmitObject(.BeginStatement)
            cb.addCodeBlock(bodyFn())
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
