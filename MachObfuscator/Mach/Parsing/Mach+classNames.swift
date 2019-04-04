import Foundation

extension Mach {
    var classNames: [String] {
        guard let classNameSection = objcClassNameSection
        else { return [] }
        let classNamesData = data.subdata(in: classNameSection.range.intRange)
        return classNamesData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}
