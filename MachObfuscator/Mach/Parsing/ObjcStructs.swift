import Foundation

enum ObjC {
    // https://opensource.apple.com/source/objc4/objc4-750.1/runtime/objc-runtime-new.h.auto.html

    struct class_64 {
        var isa: UInt64
        var superclass: UInt64
        var cacheBuckets: UInt64
        var cacheMask: UInt32
        var cacheOccupied: UInt32
        var bits: UInt64
    }

    struct class_ro_64 {
        var flags: UInt32
        var instanceStart: UInt32
        var instanceSize: UInt32
        var reserved: UInt32 // only for 64bit
        var ivarLayout: UInt64
        var name: UInt64
        var baseMethodList: UInt64
        var baseProtocols: UInt64
        var ivars: UInt64
        var weakIvarLayout: UInt64
        var baseProperties: UInt64
    }

    struct property_list {
        var entsize: UInt32
        var count: UInt32
    }

    struct property_64 {
        var name: UInt64
        var attributes: UInt64
    }

    struct class_32 {
        var isa: UInt32
        var superclass: UInt32
        var cacheBuckets: UInt32
        var cacheMask: UInt16
        var cacheOccupied: UInt16
        var bits: UInt32
    }

    struct class_ro_32 {
        var flags: UInt32
        var instanceStart: UInt32
        var instanceSize: UInt32
        var ivarLayout: UInt32
        var name: UInt32
        var baseMethodList: UInt32
        var baseProtocols: UInt32
        var ivars: UInt32
        var weakIvarLayout: UInt32
        var baseProperties: UInt32
    }

    struct property_32 {
        var name: UInt32
        var attributes: UInt32
    }

    struct category_64 {
        var name: UInt64
        var cls: UInt64
        var instanceMethods: UInt64
        var classMethods: UInt64
        var protocols: UInt64
        var instanceProperties: UInt64
        // Fields below this point are not always present on disk.
        var _classProperties: UInt64
    }

    struct category_32 {
        var name: UInt32
        var cls: UInt32
        var instanceMethods: UInt32
        var classMethods: UInt32
        var protocols: UInt32
        var instanceProperties: UInt32
        // Fields below this point are not always present on disk.
        var _classProperties: UInt32
    }
}

extension ObjC.class_64 {
    var data: UInt64 {
        return bits & 0x0000_7FFF_FFFF_FFF8
    }
}

extension ObjC.class_32 {
    var data: UInt32 {
        return bits & 0xFFFF_FFFC
    }
}
