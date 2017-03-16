//
//  TypeNameTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/26/16.
//
//

import XCTest
@testable import SwiftPoet

class TypeNameTests: XCTestCase {

    func testCustomTypeName() {
        let typeStr = "Cell"
        let type = TypeName(keyword: typeStr)

        XCTAssertEqual(type.literalValue(), typeStr)
    }

    func testObject() {
        let typeStr = "Object"
        let type = TypeName(keyword: typeStr)

        XCTAssertEqual(type.literalValue(), typeStr)
    }

    func testStaticTypes() {
        let a = [Bool.self, Int.self, Double.self, Any.self, String.self] as [Any]

        for type in a {
            let typeStr = "\(type)"
            let typeName = TypeName(keyword: typeStr)
            let optionalTypeName = TypeName(keyword: typeStr, optional: true)
            XCTAssertEqual(typeName.literalValue(), typeStr)
            XCTAssertEqual(optionalTypeName.literalValue(), "\(typeStr)?")
        }
    }

    func testGenerics() {
        let arrayTypeStr = "Array<Any>"
        let dictTypeStr = "Dictionary<String,Any>"
        let arrayTypeName = TypeName(keyword: arrayTypeStr)
        let dictTypeName = TypeName(keyword: dictTypeStr)

        XCTAssertEqual(arrayTypeName.literalValue(), arrayTypeStr)
        XCTAssertNotNil(arrayTypeName.leftInnerType)
        XCTAssertEqual(arrayTypeName.leftInnerType?.literalValue() ?? "", "Any")

        XCTAssertEqual(dictTypeName.literalValue(), dictTypeStr)
        XCTAssertNotNil(dictTypeName.leftInnerType)
        XCTAssertNotNil(dictTypeName.rightInnerType)
        XCTAssertEqual(dictTypeName.leftInnerType?.literalValue() ?? "", "String")
        XCTAssertEqual(dictTypeName.rightInnerType?.literalValue() ?? "", "Any")
    }

    func testArrayType() {
        let typeStr = "[Any]"
        let complexTypeStr = "[Double?]?"
        let typeName = TypeName(keyword: typeStr)
        let complexTypeName = TypeName(keyword: complexTypeStr)

        XCTAssertEqual(typeName.literalValue(), "Array<Any>")
        XCTAssertNotNil(typeName.leftInnerType)
        XCTAssertEqual(typeName.leftInnerType?.literalValue() ?? "", "Any")

        XCTAssertEqual(complexTypeName.literalValue(), "Array<Double?>?")
        XCTAssertTrue(complexTypeName.optional)
        XCTAssertNotNil(complexTypeName.leftInnerType)
        XCTAssertEqual(complexTypeName.leftInnerType?.literalValue() ?? "", "Double?")
    }

    func testDictionaryType() {
        let typeStr = "[String:Any]"
        let complexTypeStr = "[String?:Any]?"
        let typeName = TypeName(keyword: typeStr)
        let complexTypeName = TypeName(keyword: complexTypeStr)


        XCTAssertEqual(typeName.literalValue(), "Dictionary<String,Any>")
        XCTAssertNotNil(typeName.leftInnerType)
        XCTAssertNotNil(typeName.rightInnerType)
        XCTAssertEqual(typeName.leftInnerType?.literalValue() ?? "", "String")
        XCTAssertEqual(typeName.rightInnerType?.literalValue() ?? "", "Any")

        XCTAssertEqual(complexTypeName.literalValue(), "Dictionary<String?,Any>?")
        XCTAssertTrue(complexTypeName.optional)
        XCTAssertNotNil(complexTypeName.leftInnerType)
        XCTAssertNotNil(complexTypeName.rightInnerType)
        XCTAssertTrue(complexTypeName.leftInnerType?.optional ?? false)
        XCTAssertEqual(complexTypeName.leftInnerType?.literalValue() ?? "", "String?")
        XCTAssertEqual(complexTypeName.rightInnerType?.literalValue() ?? "", "Any")
    }

    func testClosure() {
        let typeStr = "(String, String) -> Int"
        let optionalTypeStr = "((String, Dictionary<Int>) -> Array<String>)?"
        let typeName = TypeName(keyword: typeStr)
        let optionalTypeName = TypeName(keyword: optionalTypeStr)

        XCTAssertEqual(typeName.literalValue(), typeStr)
        XCTAssertNotNil(typeName.innerTypes.first)
        XCTAssertEqual(typeName.innerTypes[1].literalValue(), "String")
        XCTAssertEqual(typeName.keyword, "Closure")

        XCTAssertEqual(optionalTypeName.literalValue(), optionalTypeStr)
        XCTAssertNotNil(optionalTypeName.innerTypes.first)
        XCTAssertEqual(optionalTypeName.keyword, "Closure")
    }

    func testRegexMatches() {
        XCTAssertTrue(TypeName.containsGenerics("Array<String>"))
        XCTAssertTrue(TypeName.containsGenerics("Array<String>?"))
        XCTAssertTrue(TypeName.containsGenerics("Dictionary<String, String>"))
        XCTAssertTrue(TypeName.containsGenerics("Dictionary<String, String>?"))
        XCTAssertFalse(TypeName.containsGenerics("Array<>"))
        XCTAssertFalse(TypeName.containsGenerics("Array<>?"))
        XCTAssertFalse(TypeName.containsGenerics("String"))
        XCTAssertFalse(TypeName.containsGenerics("String?"))

        XCTAssertTrue(TypeName.isOptional("String?"))
        XCTAssertFalse(TypeName.isOptional("String"))

        XCTAssertTrue(TypeName.isArray("[String]"))
        XCTAssertTrue(TypeName.isArray("[String]?"))
        XCTAssertFalse(TypeName.isArray("[]?"))
        XCTAssertFalse(TypeName.isArray("[]?"))
        XCTAssertFalse(TypeName.isArray("String?"))
        XCTAssertFalse(TypeName.isArray("String?"))
        XCTAssertFalse(TypeName.isArray("[String?"))

        XCTAssertTrue(TypeName.isDictionary("[String:String]"))
        XCTAssertTrue(TypeName.isDictionary("[String: String]?"))
        XCTAssertTrue(TypeName.isDictionary("[String?: String?]?"))
        XCTAssertFalse(TypeName.isDictionary("[:]?"))
        XCTAssertFalse(TypeName.isDictionary("[String:]?"))
        XCTAssertFalse(TypeName.isDictionary("String?"))
        XCTAssertFalse(TypeName.isDictionary("String?"))
        XCTAssertFalse(TypeName.isDictionary("[String:?"))

        XCTAssertTrue(TypeName.isClosure("(String) -> Int"))
        XCTAssertTrue(TypeName.isClosure("(String, String) -> Array<String>"))
        XCTAssertFalse(TypeName.isClosure("String ->"))
        XCTAssertTrue(TypeName.isOptionalClosure("((String, String) -> Int)?"))
        XCTAssertFalse(TypeName.isOptionalClosure("(String, String) -> Int?"))
    }

}
