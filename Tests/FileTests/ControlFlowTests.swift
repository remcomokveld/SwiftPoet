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
        let left = CodeBlock.builder().addLiteral("let name").build()
        let right = CodeBlock.builder().addLiteral("NSDate() as? String").build()
        let comparison = ComparisonList(lhs: left, comparator: .OptionalCheck, rhs: right)

        let controlFlow = ControlFlow.ifControlFlow(comparison) {
            return CodeBlock.builder().addLiteral("print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "if let name = NSDate() as? String {\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testIfStatement() {
        let left = CodeBlock.builder().addLiteral("[1, 2, 3].count").build()
        let right = CodeBlock.builder().addLiteral("0").build()
        let comparison = ComparisonList(lhs: left, comparator: .GreaterThan, rhs: right)

        let controlFlow = ControlFlow.ifControlFlow(comparison) {
            return CodeBlock.builder().addLiteral("print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "if [1, 2, 3].count > 0 {\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testGuardStatement() {
        let left = CodeBlock.builder().addLiteral("[1, 2, 3].count").build()
        let right = CodeBlock.builder().addLiteral("1").build()
        let comparison = ComparisonList(lhs: left, comparator: .LessThanOrEqualTo, rhs: right)

        let controlFlow = ControlFlow.guardControlFlow(comparison) {
            return CodeBlock.builder().addLiteral("print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "guard [1, 2, 3].count <= 1 else {\n" +
        "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testIfElseIfElseStatement() {
        let leftOne = CodeBlock.builder().addLiteral("let val").build()
        let rightOne = CodeBlock.builder().addLiteral( "optionalValueOne").build()
        let comparisonOne = ComparisonList(lhs: leftOne, comparator: .OptionalCheck, rhs: rightOne)

        let leftTwo = CodeBlock.builder().addLiteral("let val").build()
        let rightTwo = CodeBlock.builder().addLiteral("optionalValueTwo").build()
        let comparisonTwo = ComparisonList(lhs: leftTwo, comparator: .OptionalCheck, rhs: rightTwo)

        let cb = CodeBlock.builder()
            .addCodeBlock(ControlFlow.ifControlFlow(comparisonOne) {
                return CodeBlock.builder().addLiteral("print(\"Inside if statement\")").build()
            })
            .addCodeBlock(ControlFlow.elseIfControlFlow(comparisonTwo) {
                return CodeBlock.builder().addLiteral("print(\"Inside if else statement\")").build()
            })
            .addCodeBlock(ControlFlow.elseControlFlow(nil) {
                return CodeBlock.builder().addLiteral("print(\"Inside else statement\")").build()
            })
            .build()

        let result =
        "\n" +
        "if let val = optionalValueOne {\n" +
        "    print(\"Inside if statement\")\n" +
        "}\n" +
        "else if let val = optionalValueTwo {\n" +
        "    print(\"Inside if else statement\")\n" +
        "}\n" +
        "else {\n" +
        "    print(\"Inside else statement\")\n" +
        "}"

//        print(result)
//        print(cb.toString())

        XCTAssertEqual(result, cb.toString())
    }

    func testTwoOptionals() {
        let leftOne = CodeBlock.builder().addLiteral("let name").build()
        let rightOne = CodeBlock.builder().addLiteral("NSDate() as? String").build()
        let comparisonOne = ComparisonListItem(comparison: Comparison(lhs: leftOne, comparator: .OptionalCheck, rhs: rightOne))

        let leftTwo = CodeBlock.builder().addLiteral("let age").build()
        let rightTwo = CodeBlock.builder().addLiteral("100 as? String").build()
        let comparisonTwo = ComparisonListItem(comparison: Comparison(lhs: leftTwo, comparator: .OptionalCheck, rhs: rightTwo), requirement: Requirement.OptionalList)

        let comparisons = ComparisonList(list: [comparisonOne, comparisonTwo])

        let controlFlow = ControlFlow.ifControlFlow(comparisons) {
            return CodeBlock.builder().addLiteral("print(\"Crazy conversion!!!\")").build()
        }

        let result =
        "if let name = NSDate() as? String, let age = 100 as? String {\n" +
            "    print(\"Crazy conversion!!!\")\n" +
        "}"

//        print(result)
//        print(controlFlow.toString())

        XCTAssertEqual(result, controlFlow.toString())
    }

    func testColsure() {
        let closure = ControlFlow.closureControlFlow("key, value", canThrow: true, returnType: "[String]") {
            let left = CodeBlock.builder().addLiteral("key").build()
            let right = CodeBlock.builder().addLiteral("key").build()
            return CodeBlock.builder()
                .addCodeLine("let result = [String]()")
                .addCodeBlock(ControlFlow.ifControlFlow(ComparisonList(lhs: left, comparator: .OptionalCheck, rhs:right)) {
                    return CodeBlock.builder().addLiteral("result.append(key + value)").build()
                })
                .addCodeLine("return result")
                .build()
        }

        let result =
        " {\n" +
        "    ( key, value ) throws -> [String] in\n" +
        "        \n" +
        "        let result = [String]()\n" +
        "        if key = key {\n" +
        "            result.append(key + value)\n" +
        "        }\n" +
        "        return result\n" +
        "}"

        print(closure.toString())
        print(result)

        XCTAssertEqual(closure.toString(), result)
    }



}
