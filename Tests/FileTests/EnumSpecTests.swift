//
//  EnumSpecTests.swift
//  Cleanroom Project
//
//  Created by  on 11/9/15.
//  Copyright (c) 2015 Gilt Groupe. All rights reserved.
//

import XCTest
import SwiftPoet

class EnumSpecTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testEnumNoInheritance() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])

        let e = eb.build()
        let result =
        "/**\n" +
        "    This is a test enum\n" +
        "*/\n" +
        "private enum Test {\n" +
        "\n" +
        "}"

//        print(e.toString())
//        print(result)

        XCTAssertEqual(e.toString(), result)
    }

    func testEnumCamelCaseName() {
        let eb = EnumSpec.builder("testName")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])

        let e = eb.build()

        XCTAssertEqual(e.name, "TestName")
    }

    func testEnumNameWithSpace() {
        let eb = EnumSpec.builder("test test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])

        let e = eb.build()

        XCTAssertEqual(e.name, "TestTest")
    }

    func testEnumNameWithUnderscore() {
        let eb = EnumSpec.builder("test_test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])

        let e = eb.build()

        XCTAssertEqual(e.name, "TestTest")
    }

    func testEnumWithClassInheritance() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])
        let a = eb.addSuperType(TypeName.StringType)
        print(a)

        let e = eb.build()
        let result =
        "/**\n" +
        "    This is a test enum\n" +
        "*/\n" +
        "private enum Test: String {\n" +
        "\n" +
        "}"

        XCTAssertEqual(result, e.toString())
    }

    func testEnumWithClassAndProtocolInheritnace() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])
        eb.addSuperType(TypeName.StringType)
        eb.addProtocols([TypeName(keyword: "TestProtocol"), TypeName(keyword: "OtherProtocol")])

        let e = eb.build()
        let result =
        "/**\n" +
        "    This is a test enum\n" +
        "*/\n" +
        "private enum Test: String, TestProtocol, OtherProtocol {\n" +
        "\n" +
        "}"

        print(e.toString())
        print(result)

        XCTAssertEqual(result, e.toString())
    }

    func testEnumWithProtocolInheritance() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])
        eb.addProtocols([TypeName(keyword: "TestProtocol"), TypeName(keyword: "OtherProtocol")])

        let e = eb.build()
        let result =
        "/**\n" +
        "    This is a test enum\n" +
        "*/\n" +
        "private enum Test: TestProtocol, OtherProtocol {\n" +
        "\n" +
        "}"

        XCTAssertEqual(result, e.toString())
    }

    func testEnumSingleField() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])
        eb.addProtocols([TypeName(keyword: "TestProtocol"), TypeName(keyword: "OtherProtocol")])

        let f1 = FieldSpec.builder("test_case_one")
        f1.addDescription("This is the first test case")
        let cb1 = CodeBlock.builder()
        cb1.addLiteral("\"test_case_one\"")

        f1.addInitializer(cb1.build())

        eb.addFieldSpec(f1.build())

        let e = eb.build()

        let result =
        "/**\n" +
        "    This is a test enum\n" +
        "*/\n" +
        "private enum Test: TestProtocol, OtherProtocol {\n" +
        "    // This is the first test case\n" +
        "    case TestCaseOne = \"test_case_one\"\n" +
        "}"

        XCTAssertEqual(result, e.toString())
    }

    func testEnumManyFeilds() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])
        eb.addProtocols([TypeName(keyword: "TestProtocol"), TypeName(keyword: "OtherProtocol")])

        for i in 1...10 {
            let f1 = FieldSpec.builder("test_case_\(i)")
            f1.addDescription("This is the \(i)th case")

            if (i % 2 == 0) {
                let cb1 = CodeBlock.builder()
                cb1.addLiteral("\"test_case_\(i)\"")
                f1.addInitializer(cb1.build())
            }

            eb.addFieldSpec(f1.build())
        }

        let e = eb.build()

        let result =
        "/**\n" +
        "    This is a test enum\n" +
        "*/\n" +
        "private enum Test: TestProtocol, OtherProtocol {\n" +
        "    // This is the 1th case\n" +
        "    case TestCase1\n" +
        "    // This is the 2th case\n" +
        "    case TestCase2 = \"test_case_2\"\n" +
        "    // This is the 3th case\n" +
        "    case TestCase3\n" +
        "    // This is the 4th case\n" +
        "    case TestCase4 = \"test_case_4\"\n" +
        "    // This is the 5th case\n" +
        "    case TestCase5\n" +
        "    // This is the 6th case\n" +
        "    case TestCase6 = \"test_case_6\"\n" +
        "    // This is the 7th case\n" +
        "    case TestCase7\n" +
        "    // This is the 8th case\n" +
        "    case TestCase8 = \"test_case_8\"\n" +
        "    // This is the 9th case\n" +
        "    case TestCase9\n" +
        "    // This is the 10th case\n" +
        "    case TestCase10 = \"test_case_10\"\n" +
        "}"

        XCTAssertEqual(result, e.toString())
    }

    func testEnumWithFunction() {
        let eb = EnumSpec.builder("test")
        eb.addDescription("This is a test enum")
        eb.addModifiers([Modifier.Private, Modifier.Mutating])
        eb.addProtocols([TypeName(keyword: "TestProtocol"), TypeName(keyword: "OtherProtocol")])

        let f1 = FieldSpec.builder("test_case_one")
        f1.addDescription("This is the first case")
        let cb1 = CodeBlock.builder()
        cb1.addLiteral("\"test_case_one\"")

        f1.addInitializer(cb1.build())

        eb.addFieldSpec(f1.build())


        let e = eb.build()
        print(e.toString())

        XCTAssertTrue(true)
    }
}
