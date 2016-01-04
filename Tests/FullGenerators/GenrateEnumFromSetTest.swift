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
    var publicApiJSON: NSDictionary!
    typealias JSON = [String : AnyObject]

    override func setUp() {
        super.setUp()

        if let path = NSBundle(forClass: GenrateEnumFromSetTest.self).pathForResource("gilt_public_api", ofType: "json"),
            let jsonData = NSData(contentsOfFile: path) {

                do {
                    publicApiJSON = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions(rawValue: 0)) as? NSDictionary
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

        let e = EnumSpec.builder(data["name"] as! String)
                .addSuperType(TypeName.StringType)
                .addModifier(.Public)
                .addDescription(data["description"] as? String)
                .addFieldSpecs(
                    values.map { value in
                        let name = value["name"] as! String
                        let description = value["description"] as? String
                        return FieldSpec.builder(name)
                                .addInitializer(CodeBlock.builder().addEmitObject(.EscapedString, any: name).build())
                                .addDescription(description)
                                .build()
                    }
                ).build()

        print(e.toString())

        XCTAssertTrue(true)
    }
}
