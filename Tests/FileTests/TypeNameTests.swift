//
//  TypeNameTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/26/16.
//
//

import XCTest
import SwiftPoet

class TypeNameTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        let typeStr = "[String:Any?]?"
        let type = TypeName(keyword: typeStr)

        XCTAssertEqual(type.literalValue(), typeStr)
    }

    func testObject() {
        let typeStr = "Object"
        let type = TypeName(keyword: typeStr)

        XCTAssertEqual(type.literalValue(), typeStr)
    }
}
