//
//  SymbolsReporting.swift
//  MachObfuscator
//

import Foundation

protocol SymbolsReporter {
    func reportObjcMangling(map: SymbolManglingMap)
}

class NoReporter: SymbolsReporter {
    func reportObjcMangling(map _: SymbolManglingMap) {}
}

class ConsoleReporter: SymbolsReporter {
    func reportObjcMangling(map: SymbolManglingMap) {
        LOGGER.info("===== ObjC obfuscation report =====")
        LOGGER.info("Classes mapping:\n\(map.classNames.sorted(by: <).map { "\($0) -> \($1)" }.joined(separator: "\n"))")
        LOGGER.info("Selectors mapping:\n\(map.selectors.sorted(by: <).map { "\($0) -> \($1)" }.joined(separator: "\n"))")
    }
}
