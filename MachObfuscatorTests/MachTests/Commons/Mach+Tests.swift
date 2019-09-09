import Foundation

extension Mach {
    mutating func setEmptyRegionFor(section sectionName: String, segment segmentName: String) {
        let segmentIndex = segments.firstIndex(where: { $0.name == segmentName })!
        let sectionIndex = segments[segmentIndex].sections.firstIndex(where: { $0.name == sectionName })!
        segments[segmentIndex].sections[sectionIndex].range = 0 ..< 0
    }
}
