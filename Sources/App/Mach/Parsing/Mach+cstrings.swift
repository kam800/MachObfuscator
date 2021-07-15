import Foundation

extension Mach {
    var cstrings: [String] {
        guard let cstringSection = cstringSection,
            !cstringSection.range.isEmpty
        else { return [] }
        let cstringData = data.subdata(in: cstringSection.range.intRange)
        return cstringData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}
