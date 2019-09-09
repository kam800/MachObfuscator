//
//  ObjcSymbols+Impl.swift
//  MachObfuscator
//

import Foundation

/// Architecture-erased protocol for 32/64 ObjC images
private protocol ObjcImage {
    func getObjectsFromList<Element>(section list: Mach.Section?, creator: (Int) -> Element) -> [Element]
    func create(offset: Int) -> ObjcClass
    func create(offset: Int) -> ObjcCategory
    func create(offset: Int) -> ObjcProtocol
}

/// Architecture-specific protocol for 32/64 ObjC images
private protocol ObjcArchitecture {
    // class_ro_t has padding that is present only in 32-bit version so we have to choose approriate struct.
    // For other objc metadata generic 32/64-bit structs are enough.
    associatedtype ClassData: ImageObjClass

    typealias PointerType = ClassData.PointerType
}

private protocol ObjcArchitecture32: ObjcArchitecture where ClassData == ObjC.class_32 {}

private protocol ObjcArchitecture64: ObjcArchitecture where ClassData == ObjC.class_64 {}

private protocol FromMach {
    init(mach: Mach, offset: Int)
    /// Structure describing raw metadata structure in image
    associatedtype Raw

    var mach: Mach { get }
    var offset: Int { get }
}

private extension FromMach {
    var raw: Raw {
        return mach.getStruct(atFileOffset: offset)
    }
}

private struct ObjcMethodImpl<Arch: ObjcArchitecture>: ObjcMethod, FromMach, CustomStringConvertible {
    typealias Raw = ObjC.method_t<Arch.PointerType>

    fileprivate let mach: Mach
    fileprivate let offset: Int

    init(mach: Mach, offset: Int) {
        self.mach = mach
        self.offset = offset
    }

    var name: StringInData {
        return mach.getCString(fromVmOffset: raw.name)
    }

    var methType: StringInData {
        return mach.getCString(fromVmOffset: raw.types)
    }

    var description: String {
        return "\(name): \(methType)"
    }
}

private struct ObjcIvarImpl<Arch: ObjcArchitecture>: ObjcIvar, FromMach, CustomStringConvertible {
    typealias Raw = ObjC.ivar_t<Arch.PointerType>

    fileprivate let mach: Mach
    fileprivate let offset: Int

    init(mach: Mach, offset: Int) {
        self.mach = mach
        self.offset = offset
    }

    var name: StringInData {
        return mach.getCString(fromVmOffset: raw.name)
    }

    var type: StringInData {
        return mach.getCString(fromVmOffset: raw.type)
    }

    var description: String {
        return "\(name): \(type)"
    }
}

private struct ObjcPropertyImpl<Arch: ObjcArchitecture>: ObjcProperty, FromMach, CustomStringConvertible {
    typealias Raw = ObjC.property_t<Arch.PointerType>

    fileprivate let mach: Mach
    fileprivate let offset: Int

    init(mach: Mach, offset: Int) {
        self.mach = mach
        self.offset = offset
    }

    var name: StringInData {
        return mach.getCString(fromVmOffset: raw.name)
    }

    var attributes: StringInData {
        return mach.getCString(fromVmOffset: raw.attributes)
    }

    var description: String {
        return "\(name): \(attributes)"
    }
}

private struct ObjcClassImpl<Arch: ObjcArchitecture>: ObjcClass, FromMach, CustomStringConvertible {
    typealias Raw = Arch.ClassData
    fileprivate let mach: Mach
    fileprivate let offset: Int

    init(mach: Mach, offset: Int) {
        self.mach = mach
        self.offset = offset
    }

    var ivarLayout: StringInData? {
        guard class_ro.ivarLayout != 0 else {
            return nil
        }
        return mach.getCString(fromVmOffset: class_ro.ivarLayout)
    }

    var name: MangledObjcClassNameInData {
        return mach.getCString(fromVmOffset: class_ro.name)
    }

    var methods: [ObjcMethod] {
        // methods_list is entsize_list_tt with flags=0x3
        let list: [ObjcMethodImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: class_ro.baseMethodList, flags: 0x03)
        return list
    }

    var ivars: [ObjcIvar] {
        // ivar_list is entsize_list_tt with flags=0
        let list: [ObjcIvarImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: class_ro.ivars)
        return list
    }

    var properties: [ObjcProperty] {
        // property_list is entsize_list_tt with flags=0
        let list: [ObjcPropertyImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: class_ro.baseProperties)
        return list
    }

    var description: String {
        return "Class \(name) methods: \(methods) properties:\(properties) ivars: \(ivars)"
    }

    private var class_ro: Arch.ClassData.RODataType {
        return mach.getStruct(fromVmOffset: raw.data)
    }
}

private struct ObjcCategoryImpl<Arch: ObjcArchitecture>: ObjcCategory, FromMach, CustomStringConvertible {
    typealias Raw = ObjC.category_t<Arch.PointerType>
    fileprivate let mach: Mach
    fileprivate let offset: Int

    init(mach: Mach, offset: Int) {
        self.mach = mach
        self.offset = offset
    }

    var name: MangledObjcClassNameInData {
        return mach.getCString(fromVmOffset: raw.name)
    }

    var cls: ObjcClass? {
        guard raw.cls != 0 else {
            return nil
        }
        let offset = mach.fileOffset(fromVmOffset: raw.cls)
        return ObjcClassImpl<Arch>(mach: mach, offset: offset)
    }

    var methods: [ObjcMethod] {
        // methods_list is entsize_list_tt with flags=0x3
        let list: [ObjcMethodImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: raw.instanceMethods, flags: 0x03)
        return list
    }

    var properties: [ObjcProperty] {
        // property_list is entsize_list_tt with flags=0
        let list: [ObjcPropertyImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: raw.instanceProperties)
        return list
    }

    var description: String {
        return "Category \(cls?.name.value ?? "")+\(name) methods: \(methods) properties:\(properties)"
    }
}

private struct ObjcProtocolImpl<Arch: ObjcArchitecture>: ObjcProtocol, FromMach, CustomStringConvertible {
    typealias Raw = ObjC.protocol_t<Arch.PointerType>
    fileprivate let mach: Mach
    fileprivate let offset: Int

    init(mach: Mach, offset: Int) {
        self.mach = mach
        self.offset = offset
    }

    var name: MangledObjcClassNameInData {
        return mach.getCString(fromVmOffset: raw.name)
    }

    var methods: [ObjcMethod] {
        // methods_list is entsize_list_tt with flags=0x3
        let list: [ObjcMethodImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: raw.instanceMethods, flags: 0x03)
        return list
    }

    var properties: [ObjcProperty] {
        // property_list is entsize_list_tt with flags=0
        let list: [ObjcPropertyImpl<Arch>] = mach.get_entsize_list_tt(fromVmOffset: raw.instanceProperties)
        return list
    }

    var description: String {
        return "Protocol \(name) methods: \(methods) properties:\(properties)"
    }
}

private class MachArchitecture<PointerType: UnsignedInteger, Me: ObjcArchitecture>: ObjcImage {
    private let mach: Mach
    init(mach: Mach) {
        self.mach = mach
    }

    private func getObjectsOffsetsFromList(section list: Mach.Section?) -> [Int] {
        guard let objcList = list else {
            return []
        }
        let objectVMAddresses: [PointerType] = mach.data.getStructs(fromRange: objcList.range.intRange)
        let objectFileAddresses: [Int] = objectVMAddresses.map(mach.fileOffset(fromVmOffset:))
        return objectFileAddresses
    }

    func getObjectsFromList<Element>(section list: Mach.Section?, creator: (Int) -> Element) -> [Element] {
        return getObjectsOffsetsFromList(section: list).map { creator($0) }
    }

    func create(offset: Int) -> ObjcClass {
        return ObjcClassImpl<Me>(mach: mach, offset: offset)
    }

    func create(offset: Int) -> ObjcCategory {
        return ObjcCategoryImpl<Me>(mach: mach, offset: offset)
    }

    func create(offset: Int) -> ObjcProtocol {
        return ObjcProtocolImpl<Me>(mach: mach, offset: offset)
    }
}

private class Mach32: MachArchitecture<Mach32.PointerType, Mach32>, ObjcArchitecture32 {}

private class Mach64: MachArchitecture<Mach64.PointerType, Mach64>, ObjcArchitecture64 {}

extension Mach {
    private var as32: Mach32 {
        return Mach32(mach: self)
    }

    private var as64: Mach64 {
        return Mach64(mach: self)
    }

    private var asArchitecture: ObjcImage {
        switch data.magic {
        case MH_MAGIC_64:
            return as64
        case MH_MAGIC:
            return as32
        default:
            fatalError("Unsupported mach binary magic \(String(data.magic ?? 0, radix: 0x10, uppercase: true))")
        }
    }

    var objcClasses: [ObjcClass] {
        return asArchitecture.getObjectsFromList(section: objcClasslistSection, creator: asArchitecture.create(offset:))
    }

    var objcCategories: [ObjcCategory] {
        return asArchitecture.getObjectsFromList(section: objcCatlistSection, creator: asArchitecture.create(offset:))
    }

    var objcProtocols: [ObjcProtocol] {
        return asArchitecture.getObjectsFromList(section: objcProtocollistSection, creator: asArchitecture.create(offset:))
    }
}

private extension Mach {
    func getStruct<T>(atFileOffset offset: Int) -> T {
        return data.getStruct(atOffset: offset)
    }

    func getStruct<T, I: UnsignedInteger>(fromVmOffset offset: I) -> T {
        let objectFileAddress = fileOffset(fromVmOffset: offset)
        return getStruct(atFileOffset: objectFileAddress)
    }

    func getCString<R, I: UnsignedInteger>(fromVmOffset offset: I) -> R where R: StringInData {
        return data.getCString(atOffset: fileOffset(fromVmOffset: offset))
    }

    func get_entsize_list_tt<Element: FromMach, I: UnsignedInteger>(fromVmOffset offset: I, flags: UInt32 = 0) -> [Element] {
        guard offset != 0 else {
            // No list
            return []
        }
        let listFileOffset = fileOffset(fromVmOffset: offset)
        let list: ObjC.entsize_list_tt = getStruct(atFileOffset: listFileOffset)
        let elementSize = list.entsizeAndFlags & ~flags

        let expectedSize = MemoryLayout<Element.Raw>.size
        guard elementSize == expectedSize else {
            fatalError(
                """
                List of \(Element.self) defines entsize=\(elementSize), while \(expectedSize) expected.
                Looks like the binary is malformed.
                """
            )
        }

        let elements: [Element] = (0 ..< list.count).map { idx in
            Element(mach: self, offset: listFileOffset + MemoryLayout<ObjC.entsize_list_tt>.size + Int(idx * elementSize))
        }
        return elements
    }
}
