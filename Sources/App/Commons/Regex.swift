//
//  Regex.swift
//  MachObfuscator
//

import Foundation

extension Collection where Element == String {
    /// Filters collection, only elements matching at least one of the regular expressions are returned.
    func matching(regexes: [NSRegularExpression]) -> [Self.Element] {
        guard !regexes.isEmpty else {
            // nothing to do
            return []
        }
        return filter { string in
            regexes.contains(where: { regex in
                regex.firstMatch(in: string) != nil
            })
        }
    }
}
