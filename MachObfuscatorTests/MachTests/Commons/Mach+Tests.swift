import Foundation

extension Mach {
    mutating func setEmptyRegionFor(section sectionName: String, segment segmentName: String) {
        let segmentIndex = segments.firstIndex(where: { $0.name == segmentName })!
        let sectionIndex = segments[segmentIndex].sections.firstIndex(where: { $0.name == sectionName })!
        segments[segmentIndex].sections[sectionIndex].range = 0 ..< 0
    }
}

extension Mach {
    // Classnames in __objc_classname section.
    var classNamesInSection: [String] {
        guard let classNameSection = objcClassNameSection,
            !classNameSection.range.isEmpty
        else { return [] }
        let classNamesData = data.subdata(in: classNameSection.range.intRange)
        return classNamesData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}
