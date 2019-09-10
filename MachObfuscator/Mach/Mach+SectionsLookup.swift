import Foundation

extension Mach {
    func section(_ sectionName: String, segment segmentName: String) -> Section? {
        return segments
            .first(where: { $0.name == segmentName })?
            .sections
            .first(where: { $0.name == sectionName })
    }

    var objcMethNameSection: Section? {
        return section("__objc_methname", segment: "__TEXT")
    }

    var objcMethTypeSection: Section? {
        return section("__objc_methtype", segment: "__TEXT")
    }

    var objcClassNameSection: Section? {
        return section("__objc_classname", segment: "__TEXT")
    }

    var objcClasslistSection: Section? {
        return section("__objc_classlist", segment: "__DATA")
    }

    var objcProtocollistSection: Section? {
        return section("__objc_protolist", segment: "__DATA")
    }

    var objcCatlistSection: Section? {
        return section("__objc_catlist", segment: "__DATA")
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
        "__swift5_typeref",
        "__swift5_reflstr",
    ]

    var swiftReflectionSections: [Section] {
        return segments.first { $0.name == "__TEXT" }?
            .sections
            .filter { Mach.swiftReflectiveSections.contains($0.name) }
            ?? []
    }
}

extension Mach {
    func fileOffset<I: UnsignedInteger>(fromVmOffset vmOffset: I) -> Int {
        guard let segment = segments.first(where: { $0.vmRange.contains(UInt64(vmOffset)) }) else {
            fatalError("vmOffset \(vmOffset) does not exist in the image")
        }

        let fileOffset = Int(segment.fileRange.lowerBound + (UInt64(vmOffset) - segment.vmRange.lowerBound))
        return fileOffset
    }
}
