//
//  PoetFile.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/25/16.
//
//

import Foundation

// Represents a list of PoetSpecs in a single file

public class PoetFile: Importable {
    private var specList: [PoetSpec]
    public var fileName: String?
    public var framework: String?
    public var fileContents: String {
        return toFile()
    }

    public var imports: Set<String> {
        return collectImports()
    }

    public init(list: [PoetSpec], framework: String? = nil) {
        if !list.isEmpty {
            self.specList = list
            self.fileName = list.first!.name
            self.framework = framework
        } else {
            self.specList = []
            self.fileName = nil
            self.framework = nil
        }
    }

    public convenience init(spec: PoetSpec, framework: String? = nil) {
        self.init(list: [spec], framework: framework)
    }

    public func add(item: PoetSpec) {
        specList.append(item)
        if fileName == nil {
            fileName = item.name
        }
    }

    public func add(items: [PoetSpec]) {
        items.forEach {
            self.add($0)
        }
    }

    public func collectImports() -> Set<String> {
        return specList.reduce(Set<String>()) { set, spec in
            return set.union(spec.collectImports())
        }
    }

    private func toFile() -> String {
        let codeWriter = CodeWriter()
        codeWriter.emitFileHeader(fileName, framework: framework, specs: specList)
        codeWriter.emitImports(imports)
        codeWriter.emitSpecs(specList)
        return codeWriter.out
    }

}
