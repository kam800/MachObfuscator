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
            LOGGER.info("\(symbolKind) removed by blacklist: \(symbols.sorted())")
        }
    }
}
