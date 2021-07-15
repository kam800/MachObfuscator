//
//  ObfuscationSymbols+Finding.swift
//  MachObfuscator
//

import Foundation

extension ObfuscationSymbols {
    static func findSymbol(obfuscationPaths: ObfuscationPaths,
                           loader: SymbolsSourceLoader,
                           symbol: String) -> [(URL, String)] {
        return (obfuscationPaths.unobfuscableDependencies.union(obfuscationPaths.obfuscableImages))
            .concurrentMap { (url) -> [(URL, String)] in
                try! loader.load(forURL: url).flatMap { (source) -> [(URL, String)] in
                    var result: [(URL, String)] = []
                    if source.cstrings.contains(symbol) {
                        result.append((url, "cstrings"))
                    }
                    if source.classNames.contains(symbol) {
                        result.append((url, "classNames"))
                    }
                    if source.selectors.contains(symbol) {
                        result.append((url, "selectors"))
                    }
                    return result
                }
            }.flatMap { $0 }
    }

    // Simpler for using in debugger
    static func findSymbolToString(obfuscationPaths: ObfuscationPaths,
                                   loader: SymbolsSourceLoader,
                                   symbol: String) -> [String] {
        return findSymbol(obfuscationPaths: obfuscationPaths, loader: loader, symbol: symbol).map { "\($0.0) -> \($0.1)" }
    }
}
