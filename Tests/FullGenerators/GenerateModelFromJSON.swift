//
//  GenerateModelFromJSON.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/20/15.
//
//

import XCTest
import SwiftPoet

class GenerateModelFromJSON: XCTestCase {

    var publicApiJSON: [String: Any]!
    typealias JSON = [String : AnyObject]

    override func setUp() {
        super.setUp()

        if let path = NSBundle(forClass: GenerateModelFromJSON.self).pathForResource("gilt_public_api", ofType: "json"),
            let jsonData = NSData(contentsOfFile: path) {

                do {
                    publicApiJSON = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any]
                } catch {
                    publicApiJSON = nil
                }
        }

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test() {
        let data: JSON = (publicApiJSON["models"] as! [JSON]).first!
        let name = data["name"]! as! String
        let fields: [JSON] = data["fields"]! as! [JSON]

        let sb = StructSpec.builder(name)
            .includeDefaultInit()
            .addModifier(.Public)
            .addDescription(data["description"] as? String)
            .addFieldSpecs(fields.map { field in
                let typeStr = specialType(field["type"] as! String)
                let typeName = TypeName(keyword: typeStr, optional: !(field["required"] as! Bool))
                return FieldSpec.builder(field["name"]! as! String, type: typeName)
                    .addDescription(field["description"] as? String)
                    .addModifier(.Public)
                    .build()
            })

        print(sb.build().toString())

        XCTAssertTrue(true)
    }

    private func specialType(type: String) -> String {
        if type == "uuid" {
            return "NSUUID"
        }
        return type
    }
}
