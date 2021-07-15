//
//  Profiling.swift
//  MachObfuscator
//

import Foundation

func time<R>(withTag tag: String, of closure: () -> R) -> R {
    let start = Date()
    let result = closure()
    let end = Date()
    LOGGER.info("#\(tag) - execution took \(end.timeIntervalSince(start)) seconds")
    return result
}
