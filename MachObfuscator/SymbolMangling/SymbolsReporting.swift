//
//  SymbolsReporting.swift
//  MachObfuscator
//

import Foundation

protocol SymbolsReporter {
    func reportObjcMangling(map: SymbolManglingMap)
    func reportBlacklistedSymbols(symbolKind: String, symbols: [String])
}

extension SymbolsReporter {
    func reportObjcMangling(map _: SymbolManglingMap) {}
    func reportBlacklistedSymbols(symbolKind _: String, symbols _: [String]) {}
}

class NoReporter: SymbolsReporter {}

class ConsoleReporter: SymbolsReporter {
    func reportObjcMangling(map: SymbolManglingMap) {
        LOGGER.info("===== ObjC obfuscation report =====")
        LOGGER.info("Classes mapping:\n\(map.classNames.sorted(by: <).map { "\($0) -> \($1)" }.joined(separator: "\n"))")
        LOGGER.info("Selectors mapping:\n\(map.selectors.sorted(by: <).map { "\($0) -> \($1)" }.joined(separator: "\n"))")
    }

    func reportBlacklistedSymbols(symbolKind: String, symbols: [String]) {
        if !symbols.isEmpty {
            // Very long lines cause problems with some tools
            LOGGER.info("\(symbolKind) removed by blacklist:\n\(symbols.sorted().chunked(into: 10).map { "\($0.joined(separator: ", "))" }.joined(separator: ",\n"))")
        }
    }
}

private extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
