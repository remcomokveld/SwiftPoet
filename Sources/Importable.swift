//
//  Importable.swift
//  SwiftPoet
//
//  Created by Kyle Dorman on 1/13/16.
//
//

#if SWIFT_PACKAGE
    import Foundation
#endif

public protocol Importable {
    var imports: Set<String> { get }

    func collectImports() -> Set<String>
}
