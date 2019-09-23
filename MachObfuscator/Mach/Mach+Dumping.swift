//
//  Mach+Dumping.swift
//  MachObfuscator
//

import Foundation

extension Image {
    func dumpMetadata() {
        machs.forEach { $0.dumpMetadata() }
    }
}

extension Mach {
    func dumpMetadata() {
        // Dump objc symbols
        LOGGER.info("===== Objc metadata start =====")
        LOGGER.info("\(objcClasses.map { "\($0)" }.joined(separator: "\n"))")
        LOGGER.info("\(objcCategories.map { "\($0)" }.joined(separator: "\n"))")
        LOGGER.info("\(objcProtocols.map { "\($0)" }.joined(separator: "\n"))")
        LOGGER.info("===== Objc metadata end =====")
    }
}
