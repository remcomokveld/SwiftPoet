//
//  GenrateEnumFromSetTest.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 11/18/15.
//
//

import XCTest
import SwiftPoet

class GenrateEnumFromSetTest: XCTestCase {
    var publicApiJSON: [String: Any]!
    typealias JSON = [String : Any]

    override func setUp() {
        super.setUp()

        if let path = Bundle(for: GenrateEnumFromSetTest.self).path(forResource: "gilt_public_api", ofType: "json"),
            let jsonData = try? Data(contentsOf: URL(fileURLWithPath: path)) {

                do {
                    publicApiJSON = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions(rawValue: 0)) as? [String: Any]
                } catch {
                    publicApiJSON = nil
                }
        }
        
    }
    
    override func tearDown() {
        super.tearDown()
    }

    func test() {
        let data: JSON = (publicApiJSON["enums"] as! [JSON]).first!
        let values = data["values"] as! [JSON]

        _ = EnumSpec.builder(for: data["name"] as! String)
            .add(superType: TypeName.StringType)
            .add(modifier: .Public)
            .add(description: data["description"] as? String)
            .add(fields:
                    values.map { value in
                        let name = value["name"] as! String
                        let description = value["description"] as? String
                        return FieldSpec.builder(for: name)
                            .add(initializer: name.toCodeBlock())
                            .add(description: description)
                            .build()
                    }
                ).build()

//        print(e.toString())

        XCTAssertTrue(true)
    }
}
