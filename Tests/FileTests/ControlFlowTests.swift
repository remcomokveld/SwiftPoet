//
//  ControlFlowTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/18/15.
//
//

import XCTest
import SwiftPoet

class ControlFlowTests: XCTestCase {

    func testIfLetStatement() {
        let leftBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "let name")

        let rightBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "NSDate() as? String")

        let comparison = ComparisonList(lhs: leftBuilder.build(), comparator: .OptionalCheck, rhs: rightBuilder.build())

        let bodyBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "print(\"Crazy conversion!!!\")")

        let controlFlow = ControlFlow.ifControlFlow(bodyBuilder.build(), comparison)

        let result =
        "if let name = NSDate() as? String {\n" +
        "\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}\n"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testIfStatement() {
        let leftBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "[1, 2, 3].count")

        let rightBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "0")

        let comparison = ComparisonList(lhs: leftBuilder.build(), comparator: .GreaterThan, rhs: rightBuilder.build())

        let bodyBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "print(\"Crazy conversion!!!\")")

        let controlFlow = ControlFlow.ifControlFlow(bodyBuilder.build(), comparison)

        let result =
        "if [1, 2, 3].count > 0 {\n" +
        "\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}\n"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testGuardStatement() {
        let leftBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "[1, 2, 3].count")

        let rightBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "1")

        let comparison = ComparisonList(lhs: leftBuilder.build(), comparator: .LessThanOrEqualTo, rhs: rightBuilder.build())

        let bodyBuilder = CodeBlock.builder().addEmitObject(.Literal, any: "print(\"Crazy conversion!!!\")")

        let controlFlow = ControlFlow.guardControlFlow(bodyBuilder.build(), comparison)

        let result =
        "guard [1, 2, 3].count <= 1 else {\n" +
        "\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}\n"

        print(result)
        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testIfElseIfElseStatement() {
        let leftBuilderOne = CodeBlock.builder().addEmitObject(.Literal, any: "let val")
        let rightBuilderOne = CodeBlock.builder().addEmitObject(.Literal, any: "optionalValueOne")
        let comparisonOne = ComparisonList(lhs: leftBuilderOne.build(), comparator: .OptionalCheck, rhs: rightBuilderOne.build())

        let leftBuilderTwo = CodeBlock.builder().addEmitObject(.Literal, any: "let val")
        let rightBuilderTwo = CodeBlock.builder().addEmitObject(.Literal, any: "optionalValueTwo")
        let comparisonTwo = ComparisonList(lhs: leftBuilderTwo.build(), comparator: .OptionalCheck, rhs: rightBuilderTwo.build())

        let bodyBuilderOne = CodeBlock.builder().addEmitObject(.Literal, any: "print(\"Inside if statement\")")
        let bodyBuilderTwo = CodeBlock.builder().addEmitObject(.Literal, any: "print(\"Inside if else statement\")")
        let bodyBuilderThree = CodeBlock.builder().addEmitObject(.Literal, any: "print(\"Inside else statement\")")

        let controlFlowIf = ControlFlow.ifControlFlow(bodyBuilderOne.build(), comparisonOne)
        let controlFlowElseIf = ControlFlow.elseIfControlFlow(bodyBuilderTwo.build(), comparisonTwo)
        let controlFlowElse = ControlFlow.elseControlFlow(bodyBuilderThree.build(), nil)

        let cb = CodeBlock.builder().addCodeBlock(controlFlowIf).addCodeBlock(controlFlowElseIf).addCodeBlock(controlFlowElse).build()

        let result =
        "\n" +
        "if let val = optionalValueOne {\n" +
        "\n" +
        "    print(\"Inside if statement\")\n" +
        "}\n" +
        "\n" +
        "else if let val = optionalValueTwo {\n" +
        "\n" +
        "    print(\"Inside if else statement\")\n" +
        "}\n" +
        "\n" +
        "else {\n" +
        "\n" +
        "    print(\"Inside else statement\")\n" +
        "}\n"

        print(result)
        print(cb.toString())

        XCTAssertEqual(result, cb.toString())
    }

}
