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
    typealias JSON = [String : Any]

    override func setUp() {
        super.setUp()
        let b = Bundle(for: GenerateModelFromJSON.self)
        print(b.bundlePath)
        print(b.resourcePath)

        if let path = Bundle(for: GenerateModelFromJSON.self).path(forResource: "gilt_public_api", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {

                do {
                    publicApiJSON = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any]
                } catch {
                    print("Failed to load bundle json")
                    publicApiJSON = nil
                }
        } else {
            print("Failed to find bundle")
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

        _ = StructSpec.builder(for: name)
            .includeDefaultInit()
            .add(modifier: .Public)
            .add(description: data["description"] as? String)
            .add(fields: fields.map { field in
                let typeStr = specialType(field["type"] as! String)
                let typeName = TypeName(keyword: typeStr, optional: !(field["required"] as! Bool))
                return FieldSpec.builder(for: field["name"]! as! String, type: typeName)
                    .add(description: field["description"] as? String)
                    .add(modifier: .Public)
                    .build()
            })

//        print(sb.build().toString())

        XCTAssertTrue(true)
    }

    fileprivate func specialType(_ type: String) -> String {
        if type == "uuid" {
            return "UUID"
        }
        return type
    }
}
