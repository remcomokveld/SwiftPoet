//
//  PrintableList.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/25/16.
//
//

import Foundation

// Represents a list of PoetSpecs in a single file

public class PrintableList: PoetPrintable {
    public private(set) var list: [PoetSpec]

    public init(list: [PoetSpec]?) {
        if let list = list {
            self.list = list
        } else {
            self.list = []
        }
    }

    public func add(item: PoetSpec) {
        list.append(item)
    }

    public func add(items: [PoetSpec]) {
        items.forEach {
            list.append($0)
        }
    }

    public func toFile() -> String {
        let fileName = list.first?.name ?? "NoName"
        let specs: [String] = list.map { spec in
            return "// \(spec.construct.stringValue) \(spec.name) \n"
        }

        let specStr = specs.joinWithSeparator("")

        let header =
        "//\n" +
        "// \(fileName).swift\n" +
        "//\n" + // Framework?
        "// Contains:\n" +
        specStr +
        "//\n" +
        "// \(generatedByAt()) \n" +
        "//\n" +
        "//\n\n"

        let imports = Array(list.reduce(Set<String>()) { (var map, spec) in
            spec.collectImports().forEach { map.insert($0) }
            return map
        }).joinWithSeparator("\nimport ")

        let specStrings: String = list.map { $0.toString() }.joinWithSeparator("\n\n")

        return header + "import " + imports + specStrings + "\n"
    }

}
