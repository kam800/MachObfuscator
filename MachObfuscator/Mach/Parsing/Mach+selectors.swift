import Foundation

extension Mach {
    var selectors: [String] {
        guard let methNameSection = objcMethNameSection,
            !methNameSection.range.isEmpty
        else { return [] }
        let methodNamesData = data.subdata(in: methNameSection.range.intRange)
        return methodNamesData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}
