import Foundation

extension Mach {
    private func section(_ sectionName: String, segment segmentName: String) -> Section? {
        return segments
            .first(where: { $0.name == segmentName })?
            .sections
            .first(where: { $0.name == sectionName })
    }

    var objcMethNameSection: Section? {
        return section("__objc_methname", segment: "__TEXT")
    }

    var objcClassNameSection: Section? {
        return section("__objc_classname", segment: "__TEXT")
    }

    var cstringSection: Section? {
        return section("__cstring", segment: "__TEXT")
    }
}

extension Mach {
    private static let swiftReflectiveSections: Set<String> = [
        "__swift3_typeref",
        "__swift3_reflstr",
        "__swift4_typeref",
        "__swift4_reflstr",
    ]

    var swiftReflectionSections: [Section] {
        return segments.first { $0.name == "__TEXT" }?
            .sections
            .filter { Mach.swiftReflectiveSections.contains($0.name) }
            ?? []
    }
}
