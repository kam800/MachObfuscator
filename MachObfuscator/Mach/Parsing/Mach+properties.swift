import Foundation

extension Mach {
    // TODO: custom setter and getter names
    var dynamicPropertyNames: [String] {
        return properties
            .filter { $0.isDynamic }
            .map { $0.name }
    }

    private var properties: [Property] {
        return classProperties + categoryProperties
    }

    private var classProperties: [Property] {
        switch data.magic {
        case MH_MAGIC_64:
            return classProperties64
        case MH_MAGIC:
            return classProperties32
        default:
            fatalError("Unsupported mach binary magic \(String(data.magic ?? 0, radix: 0x10, uppercase: true))")
        }
    }

    private var classProperties32: [Property] {
        return getClassProperties(
            dataAccessor: { (c: ObjC.class_32) -> UInt32 in c.data },
            basePropertiesAccessor: { (ro: ObjC.class_ro_32) -> UInt32 in ro.baseProperties },
            propertyNameAccessor: { (p: ObjC.property_32) -> UInt32 in p.name },
            propertyAttributesAccessor: { (p: ObjC.property_32) -> UInt32 in p.attributes }
        )
    }

    private var classProperties64: [Property] {
        return getClassProperties(
            dataAccessor: { (c: ObjC.class_64) -> UInt64 in c.data },
            basePropertiesAccessor: { (ro: ObjC.class_ro_64) -> UInt64 in ro.baseProperties },
            propertyNameAccessor: { (p: ObjC.property_64) -> UInt64 in p.name },
            propertyAttributesAccessor: { (p: ObjC.property_64) -> UInt64 in p.attributes }
        )
    }

    private func getClassProperties<Ptr: UnsignedInteger, ObjcClass, ObjcClassRO, PropertyEntry>(
        dataAccessor: (ObjcClass) -> Ptr,
        basePropertiesAccessor: (ObjcClassRO) -> Ptr,
        propertyNameAccessor: (PropertyEntry) -> Ptr,
        propertyAttributesAccessor: (PropertyEntry) -> Ptr
    ) -> [Property] {
        guard let objcClasslist = objcClasslist,
            !objcClasslist.range.isEmpty
        else { return [] }
        let objcClasslistStart = objcClasslist.range.intRange.lowerBound
        let classCount = objcClasslist.range.count / MemoryLayout<UInt64>.size
        let classVMAddresses: [Ptr] = data.getStructs(atOffset: Int(objcClasslistStart), count: classCount)
        let classFileAddresses: [Int] = classVMAddresses.map(fileOffset(fromVmOffset:))
        let classes: [ObjcClass] = classFileAddresses.map(data.getStruct(atOffset:))
        let classRoVMAddesses: [Ptr] = classes.map(dataAccessor)
        let classRoFileAddesses: [Int] = classRoVMAddesses.map(fileOffset(fromVmOffset:))
        let classRos: [ObjcClassRO] = classRoFileAddesses.map(data.getStruct(atOffset:))
        let classRosWithProperties: [ObjcClassRO] = classRos.filter { basePropertiesAccessor($0) != 0 }
        let propertyListVMAddresses: [Ptr] = classRosWithProperties.map(basePropertiesAccessor)
        let propertyListFileAddresses: [Int] = propertyListVMAddresses.map(fileOffset(fromVmOffset:))
        let addressedPropertyLists: [(Int, ObjC.property_list)] = propertyListFileAddresses.map {
            ($0, data.getStruct(atOffset: $0))
        }
        let properties: [PropertyEntry] = addressedPropertyLists.flatMap { (address, propertyList) -> [PropertyEntry] in
            let expectedSize = MemoryLayout<PropertyEntry>.size
            guard propertyList.entsize == expectedSize else {
                fatalError(
                    """
                    Property list defines entsize=\(propertyList.entsize), while \(expectedSize) expected.
                    Looks like the binary is malformed.
                    """
                )
            }
            let propertiesStart = address + MemoryLayout<ObjC.property_list>.size
            return data.getStructs(atOffset: propertiesStart, count: Int(propertyList.count))
        }
        return properties.map {
            Property(name: data.getCString(atOffset: fileOffset(fromVmOffset: propertyNameAccessor($0))),
                     attributes: data.getCString(atOffset: fileOffset(fromVmOffset: propertyAttributesAccessor($0))))
        }
    }

    private var categoryProperties: [Property] {
        switch data.magic {
        case MH_MAGIC_64:
            return categoryProperties64
        case MH_MAGIC:
            return categoryProperties32
        default:
            fatalError("Unsupported mach binary magic \(String(data.magic ?? 0, radix: 0x10, uppercase: true))")
        }
    }

    private var categoryProperties64: [Property] {
        return getCategoryProperties(
            categoryPropertiesAccessor: { (c: ObjC.category_64) -> UInt64 in c.instanceProperties },
            propertyNameAccessor: { (p: ObjC.property_64) -> UInt64 in p.name },
            propertyAttributesAccessor: { (p: ObjC.property_64) -> UInt64 in p.attributes }
        )
    }

    private var categoryProperties32: [Property] {
        return getCategoryProperties(
            categoryPropertiesAccessor: { (c: ObjC.category_32) -> UInt32 in c.instanceProperties },
            propertyNameAccessor: { (p: ObjC.property_32) -> UInt32 in p.name },
            propertyAttributesAccessor: { (p: ObjC.property_32) -> UInt32 in p.attributes }
        )
    }

    private func getCategoryProperties<Ptr: UnsignedInteger, Category, PropertyType>(
        categoryPropertiesAccessor: (Category) -> Ptr,
        propertyNameAccessor: (PropertyType) -> Ptr,
        propertyAttributesAccessor: (PropertyType) -> Ptr
    ) -> [Property] {
        guard let objcCatlist = objcCatlist,
            !objcCatlist.range.isEmpty
        else { return [] }
        let objcCatlistStart = objcCatlist.range.intRange.lowerBound
        let categoryCount = objcCatlist.range.count / MemoryLayout<Ptr>.size
        let categoryVMAddresses: [Ptr] = data.getStructs(atOffset: Int(objcCatlistStart), count: categoryCount)
        let categoryFileAddresses: [Int] = categoryVMAddresses.map(fileOffset(fromVmOffset:))
        let categories: [Category] = categoryFileAddresses.map(data.getStruct(atOffset:))
        let categoriesWithProperties: [Category] = categories.filter { categoryPropertiesAccessor($0) != 0 }
        let propertyListVMAddresses: [Ptr] = categoriesWithProperties.map(categoryPropertiesAccessor)
        let propertyListFileAddresses: [Int] = propertyListVMAddresses.map(fileOffset(fromVmOffset:))
        let addressedPropertyLists: [(Int, ObjC.property_list)] =
            propertyListFileAddresses.map { ($0, data.getStruct(atOffset: $0)) }
        let properties: [PropertyType] = addressedPropertyLists.flatMap { (address, propertyList) -> [PropertyType] in
            let expectedSize = MemoryLayout<PropertyType>.size
            guard propertyList.entsize == expectedSize else {
                fatalError(
                    """
                    Property list defines entsize=\(propertyList.entsize), while \(expectedSize) expected.
                    Looks like the binary is malformed.
                    """
                )
            }
            let propertiesStart = address + MemoryLayout<ObjC.property_list>.size
            return data.getStructs(atOffset: propertiesStart, count: Int(propertyList.count))
        }
        return properties.map {
            Property(name: data.getCString(atOffset: fileOffset(fromVmOffset: propertyNameAccessor($0))),
                     attributes: data.getCString(atOffset: fileOffset(fromVmOffset: propertyAttributesAccessor($0))))
        }
    }
}

private extension Mach {
    func fileOffset<I: UnsignedInteger>(fromVmOffset vmOffset: I) -> Int {
        return segments
            .first(where: { $0.vmRange.contains(UInt64(vmOffset)) })
            .flatMap { Int(UInt64(vmOffset) - ($0.vmRange.lowerBound - $0.fileRange.lowerBound)) }
            ?? Int(vmOffset)
    }
}

private struct Property {
    var name: String
    var attributes: String
}

extension Property {
    var isDynamic: Bool {
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
        return attributes.split(separator: ",").contains("D")
    }
}
