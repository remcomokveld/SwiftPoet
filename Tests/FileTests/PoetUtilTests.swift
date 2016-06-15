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
        PoetUtil.addUnique(data: 5, toList: &list)
        print(list)
        XCTAssertEqual(5, list.count)
    }

    func testAddDataToListNoRepeat() {
        var list = [1, 2, 3, 4]
        PoetUtil.addUnique(data: 4, toList: &list)

        XCTAssertEqual(4, list.count)
    }

    func testCleanTypeNameUnderscore() {
        let name = "test_underscore"
        XCTAssertEqual("TestUnderscore", name.cleaned(case: .TypeName))
    }

//    func testCleanTypeNameAllCaps() {
//        let name = "TEST_ALL_CAPS"
//        XCTAssertEqual("TestAllCaps", name.cleaned(case: .TypeName))
//    }

    func testTypeNameWithBrackets() {
        let name = "billing_address[street_line1]"
        XCTAssertEqual("BillingAddressStreetLine1", name.cleaned(case: .TypeName))
    }

    func testcammelCaseNameWithBrackets() {
        let name = "billing_address[street_line1]"
        XCTAssertEqual("billingAddressStreetLine1", name.cleaned(case: .ParamName))
    }

    func testCleanTypeNameSpaces() {
        let name = "test many spaces"
        XCTAssertEqual("TestManySpaces", name.cleaned(case: .TypeName))
    }

    func testCamelCaseName() {
        let name = "test"
        XCTAssertEqual("test", name.cleaned(case: .ParamName))
    }

    func testCamelCaseNameSpaces() {
        let name = "test test test"
        XCTAssertEqual("testTestTest", name.cleaned(case: .ParamName))
    }

    func testCamelCaseNameUnderscores() {
        let name = "test_test_test"
        XCTAssertEqual("testTestTest", name.cleaned(case: .ParamName))
    }

//    func testCamelCaseNameAllCaps() {
//        let name = "TEST_ALL_CAPS"
//        XCTAssertEqual("testAllCaps", name.cleaned(case: .ParamName))
//    }

    func testPeriodsInName() {
        let name = "test.periods.in.name"
        XCTAssertEqual("testPeriodsInName", name.cleaned(case: .ParamName))
    }

}
