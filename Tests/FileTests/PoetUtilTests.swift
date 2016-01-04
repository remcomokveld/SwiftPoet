//
//  PoetUtilTests.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/17/15.
//
//

import XCTest
@testable import SwiftPoet

class PoetUtilTests: XCTestCase {

    func testAddDataToList() {
        var list = [1, 2, 3, 4]
        PoetUtil.addDataToList(5, list: &list)
        print(list)
        XCTAssertEqual(5, list.count)
    }

    func testAddDataToListNoRepeat() {
        var list = [1, 2, 3, 4]
        PoetUtil.addDataToList(4, list: &list)

        XCTAssertEqual(4, list.count)
    }

    func testAddMultipleDataToList() {
        var list = [1, 2, 3, 4]
        let data = [2, 3, 4, 5, 6]

        PoetUtil.addDataToList(data) { d in
            PoetUtil.addDataToList(d, list: &list)
        }

        XCTAssertEqual(6, list.count)
    }

    func testCleanTypeNameUnderscore() {
        let name = "test_underscore"
        XCTAssertEqual("TestUnderscore", PoetUtil.cleanTypeName(name))
    }

    func testCleanTypeNameAllCaps() {
        let name = "TEST_ALL_CAPS"
        XCTAssertEqual("TestAllCaps", PoetUtil.cleanTypeName(name))
    }

    func testCleanTypeNameSpaces() {
        let name = "test many spaces"
        XCTAssertEqual("TestManySpaces", PoetUtil.cleanTypeName(name))
    }

    func testCamelCaseName() {
        let name = "test"
        XCTAssertEqual("test", PoetUtil.cleanCammelCaseString(name))
    }

    func testCamelCaseNameSpaces() {
        let name = "test test test"
        XCTAssertEqual("testTestTest", PoetUtil.cleanCammelCaseString(name))
    }

    func testCamelCaseNameUnderscores() {
        let name = "test_test_test"
        XCTAssertEqual("testTestTest", PoetUtil.cleanCammelCaseString(name))
    }

    func testCamelCaseNameAllCaps() {
        let name = "TEST_ALL_CAPS"
        XCTAssertEqual("testAllCaps", PoetUtil.cleanCammelCaseString(name))
    }

}
