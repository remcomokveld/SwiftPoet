//
//  ControlFlow.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/18/15.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

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

    public static var guardControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(type: .Guard)

    public static var ifControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(type: .If)

    public static var elseIfControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(type: .ElseIf)

    public static var elseControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(type: .Else)

    public static var whileControlFlow: (ComparisonList?, () -> CodeBlock) -> CodeBlock = ControlFlow.fnGenerator(type: .While)

    public static func repeatWhileControlFlow(comparisonList: ComparisonList, bodyFn: () -> CodeBlock) -> CodeBlock {
        return CodeBlock.builder()
            .addLiteral(any: ControlFlow.RepeatWhile.rawValue)
            .addEmitObject(type: .BeginStatement)
            .addCodeBlock(codeBlock: bodyFn())
            .addEmitObject(type: .EndStatement)
            .addLiteral(any: ControlFlow.While.rawValue)
            .addEmitObject(type: .Emitter, any: comparisonList)
            .build()
    }

    public static func forInControlFlow(iterator: Literal, iterable: Literal, bodyFn: () -> CodeBlock) -> CodeBlock {
        return CodeBlock.builder()
            .addLiteral(any: ControlFlow.For.rawValue)
            .addLiteral(any: iterator)
            .addEmitObject(type: .Literal, any: ControlFlow.ForIn.rawValue)
            .addLiteral(any: iterable)
            .addEmitObject(type: .BeginStatement)
            .addCodeBlock(codeBlock: bodyFn())
            .addEmitObject(type: .EndStatement)
            .build()
    }

    public static func closureControlFlow(parameterBlock: Literal, canThrow: Bool, returnType: Literal? , bodyFn: () -> CodeBlock) -> CodeBlock {
        let cb = CodeBlock.builder()
        let closureBlock = CodeBlock.builder()

        cb.addEmitObject(type: .BeginStatement)

        closureBlock.addLiteral(any: "(")
        closureBlock.addLiteral(any: parameterBlock)
        closureBlock.addLiteral(any: ")")
        if canThrow {
            closureBlock.addLiteral(any: "throws")
        }
        closureBlock.addLiteral(any: "->")
        if let returnType = returnType {
            closureBlock.addLiteral(any: returnType)
        } else {
            closureBlock.addLiteral(any: "Void")
        }
        closureBlock.addLiteral(any: ControlFlow.ForIn.rawValue)

        closureBlock.addEmitObject(type: .IncreaseIndentation)
        closureBlock.addCodeBlock(codeBlock: bodyFn())
        closureBlock.addEmitObject(type: .DecreaseIndentation)

        cb.addCodeBlock(codeBlock: closureBlock.build())
        cb.addEmitObject(type: .EndStatement)

        return cb.build()
    }

    public static func forControlFlow(iterator: CodeBlock, iterable: CodeBlock, execution: CodeBlock) -> CodeBlock {
        fatalError("So many loops so little time")
    }

    public static func doCatchControlFlow(doFn: () -> CodeBlock, catchFn: () -> CodeBlock) -> CodeBlock {
        let doCB = CodeBlock.builder()
        doCB.addLiteral(any: "do")
        doCB.addEmitObject(type: .BeginStatement)
        doCB.addCodeBlock(codeBlock: doFn())
        doCB.addEmitObject(type: .EndStatement)

        let catchCB = CodeBlock.builder()
        catchCB.addLiteral(any: "catch")
        catchCB.addEmitObject(type: .BeginStatement)
        catchCB.addCodeBlock(codeBlock: catchFn())
        catchCB.addEmitObject(type: .EndStatement)

        return doCB.addCodeBlock(codeBlock: catchCB.build()).build()
    }

    public static func switchControlFlow(switchValue: String, cases: [(String, CodeBlock)], defaultCase: CodeBlock? = nil) -> CodeBlock {
        let cb = CodeBlock.builder()
        cb.addEmitObject(type: .Literal, any: ControlFlow.Switch.rawValue)
        cb.addEmitObject(type: .Literal, any: switchValue)
        cb.addEmitObject(type: .BeginStatement)

        cases.forEach { caseItem in
            cb.addCodeBlock(codeBlock: ControlFlow.switchCase(caseLine: caseItem.0, execution: caseItem.1))
        }

        if let defaultCase = defaultCase {
            cb.addCodeBlock(codeBlock: ControlFlow.switchCase(caseLine: nil, execution: defaultCase))
        }

        cb.addEmitObject(type: .EndStatement)
        return cb.build()
    }

    private static func switchCase(caseLine: String?, execution: CodeBlock) -> CodeBlock {
        let caseWord = caseLine == nil ? "default" : "case"
        let cbCase = CodeBlock.builder()
        let cbCaseLineTwo = CodeBlock.builder()

        cbCase.addEmitObject(type: .Literal, any: caseWord)
        cbCase.addEmitObject(type: .Literal, any: caseLine)
        cbCase.addEmitObject(type: .Literal, any: ":")

        cbCaseLineTwo.addEmitObject(type: .IncreaseIndentation)
        cbCaseLineTwo.addCodeBlock(codeBlock: execution)
        cbCaseLineTwo.addEmitObject(type: .DecreaseIndentation)

        cbCase.addCodeBlock(codeBlock: cbCaseLineTwo.build())

        return cbCase.build()
    }

    private static func fnGenerator(type: ControlFlow) -> (ComparisonList?, () -> CodeBlock) -> CodeBlock {
        return { (comparisonList: ComparisonList?, bodyFn: () -> CodeBlock) -> CodeBlock in
            let cb = CodeBlock.builder()
                .addLiteral(any: type.rawValue)

            if type != .Else && comparisonList != nil {
                cb.addEmitObject(type: .Emitter, any: comparisonList!)
            }

            if type == .Guard {
                cb.addLiteral(any: "else")
            }

            cb.addEmitObject(type: .BeginStatement)
            cb.addCodeBlock(codeBlock: bodyFn())
            cb.addEmitObject(type: .EndStatement)
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

    @discardableResult
    public func emit(codeWriter: CodeWriter) -> CodeWriter {
        if requirement != nil {
            codeWriter.emit(type: .Literal, any: requirement!)
        }

        list.forEach { listItem in
            switch listItem {
            case .Left(let item):
                item.emit(codeWriter: codeWriter)
            case .Right(let cList):
                codeWriter.emit(type: .Literal, any: "(")
                cList.emit(codeWriter: codeWriter)
                codeWriter.emit(type: .Literal, any: ")")
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

    @discardableResult
    public func emit(codeWriter: CodeWriter) -> CodeWriter {
        if requirement != nil {
            codeWriter.emit(type: .Literal, any: requirement!.rawValue)
        }
        return comparison.emit(codeWriter: codeWriter)
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

    public func emit(codeWriter: CodeWriter) -> CodeWriter {
        let cbBuilder = CodeBlock.builder()
        cbBuilder.addEmitObjects(emitObjects: lhs.emittableObjects)
        cbBuilder.addEmitObject(type: .Literal, any: comparator.rawValue)
        cbBuilder.addEmitObjects(emitObjects: rhs.emittableObjects)
        codeWriter.emit(codeBlock: cbBuilder.build())

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
