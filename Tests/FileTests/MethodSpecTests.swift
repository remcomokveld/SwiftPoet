//
//  MethodSpecTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/17/15.
//
//

import XCTest
import SwiftPoet

class MethodSpecTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testEmptyProtocolMethod() {
        let mb = MethodSpec.builder("Test")
        mb.addParentType(.Protocol)

        let method = mb.build()

        XCTAssertEqual("func test ()", method.toString())
    }

    func testProtocolMethodOneParam() {
        let mb = MethodSpec.builder("Test")
        mb.addParentType(.Protocol)
        mb.addReturnType(TypeName.StringType)

        let pb = ParameterSpec.builder("name", type: TypeName.StringType)
        mb.addParameter(pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    :param:    name\n" +
        "*/\n" +
        "func test (name : String) -> String"

        //        print(result)
        //        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testProtocolMethodManyParam() {
        let mb = MethodSpec.builder("build_person")
        mb.addParentType(.Protocol)
        mb.addReturnType(TypeName(keyword: "Person"))

        let pb1 = ParameterSpec.builder("name", type: TypeName.StringType)
        mb.addParameter(pb1.build())
        let pb2 = ParameterSpec.builder("age", type: TypeName.IntegerType)
        mb.addParameter(pb2.build())
        let pb3 = ParameterSpec.builder("homeOwner", type: TypeName.BooleanType)
        mb.addParameter(pb3.build())
        let pb4 = ParameterSpec.builder("petName", type: TypeName.StringOptional)
        mb.addParameter(pb4.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    :param:    name\n\n" +
        "    :param:    age\n\n" +
        "    :param:    homeOwner\n\n" +
        "    :param:    petName\n" +
        "*/\n" +
        "func buildPerson (name : String, age : Int, homeOwner : Bool, petName : String?) -> Person"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testProtocolMethodOneParamWithDocs() {
        let mb = MethodSpec.builder("Test")
        mb.addParentType(.Protocol)
        mb.addReturnType(TypeName.StringType)
        mb.addDescription("This is a test description")

        let pb = ParameterSpec.builder("name", type: TypeName.StringType)
                .addDescription("The name of the test")

        mb.addParameter(pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    This is a test description\n" +
        "\n" +
        "    :param:    name The name of the test\n" +
        "*/\n" +
        "func test (name : String) -> String"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testEmptyMethod() {
        let method = MethodSpec.builder("Test")
            .addReturnType(TypeName.StringType)
            .build()

        let result =
        "func test () -> String {\n" +
        "}"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testMethodWithCodeBlock() {
        let method = MethodSpec.builder("Test")
            .addReturnType(TypeName.StringType)
            .addCode(CodeBlock.builder()
                .addLiteral("return \"test\"")
                .build())
            .build()

        let result =
        "func test () -> String {\n" +
        "    return \"test\"\n" +
        "}"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testMethodWithCodeBlockAndParam() {
        let mb = MethodSpec.builder("Test")
        mb.addReturnType(TypeName.StringType)

        let cbBuilder = CodeBlock.builder()
        cbBuilder.addEmitObject(.Literal, any: "return name")
        mb.addCode(cbBuilder.build())

        let pb = ParameterSpec.builder("name", type: TypeName.StringType)
        mb.addParameter(pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
        "    :param:    name\n" +
        "*/\n" +
        "func test (name : String) -> String {\n" +
        "    return name\n" +
        "}"

//        print(result)
//        print(method.toString())

        XCTAssertEqual(result, method.toString())
    }

    func testMethodWithGuard() {
        let mb = MethodSpec.builder("Test")
        mb.addReturnType(TypeName.StringType)

        let cbBuilder = CodeBlock.builder()
        cbBuilder.addEmitObject(.Literal, any: "return name")
        mb.addCode(cbBuilder.build())

        let pb = ParameterSpec.builder("name", type: TypeName.StringType)
        mb.addParameter(pb.build())

        let method = mb.build()

        let result =
        "/**\n" +
            "    :param:    name\n" +
            "*/\n" +
            "func test (name : String) -> String {\n" +
            "    return name\n" +
        "}"

        //        print(result)
        //        print(method.toString())
        
        XCTAssertEqual(result, method.toString())
    }

}
