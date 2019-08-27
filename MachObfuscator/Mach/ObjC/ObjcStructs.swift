import Foundation

/// Objc metadata structures with different 32-bit and 64-bit versions.
protocol ArchitectureDependent {
    /// Type of pointer for given architecture
    associatedtype PointerType: UnsignedInteger
}

protocol ImageObjClass: ArchitectureDependent {
    associatedtype RODataType: ImageObjClassRO where RODataType.PointerType == PointerType
    /// Pointer to class_ro calculated from data stored in image
    var data: PointerType { get }
}

protocol ImageObjClassRO: ArchitectureDependent {
    var ivarLayout: PointerType { get }
    var name: PointerType { get }
    var baseMethodList: PointerType { get }
    var baseProtocols: PointerType { get }
    var ivars: PointerType { get }
    var weakIvarLayout: PointerType { get }
    var baseProperties: PointerType { get }
}

enum ObjC {
    // https://opensource.apple.com/source/objc4/objc4-750.1/runtime/objc-runtime-new.h.auto.html
    struct class_64: ImageObjClass {
        typealias PointerType = UInt64

        var isa: UInt64
        var superclass: UInt64
        var cacheBuckets: UInt64
        var cacheMask: UInt32
        var cacheOccupied: UInt32
        var bits: PointerType

        typealias RODataType = ObjC.class_ro_64
        var data: PointerType {
            return bits & 0x0000_7FFF_FFFF_FFF8
        }
    }

    struct class_ro_64: ImageObjClassRO {
        typealias PointerType = UInt64

        var flags: UInt32
        var instanceStart: UInt32
        var instanceSize: UInt32
        var reserved: UInt32 // only for 64bit
        var ivarLayout: PointerType
        var name: PointerType
        var baseMethodList: PointerType
        var baseProtocols: PointerType
        var ivars: PointerType
        var weakIvarLayout: PointerType
        var baseProperties: PointerType
    }

    struct class_32: ImageObjClass {
        typealias PointerType = UInt32

        var isa: UInt32
        var superclass: UInt32
        var cacheBuckets: UInt32
        var cacheMask: UInt16
        var cacheOccupied: UInt16
        var bits: PointerType

        typealias RODataType = ObjC.class_ro_32
        var data: PointerType {
            return bits & 0xFFFF_FFFC
        }
    }

    struct class_ro_32: ImageObjClassRO {
        typealias PointerType = UInt32

        var flags: UInt32
        var instanceStart: UInt32
        var instanceSize: UInt32
        var ivarLayout: PointerType
        var name: PointerType
        var baseMethodList: PointerType
        var baseProtocols: PointerType
        var ivars: PointerType
        var weakIvarLayout: PointerType
        var baseProperties: PointerType
    }

    struct method_t<Pointer: UnsignedInteger>: ArchitectureDependent {
        typealias PointerType = Pointer
        var name: PointerType // SEL
        var types: PointerType // meth type string
        var imp: PointerType // code
    }

    struct ivar_t<Pointer: UnsignedInteger>: ArchitectureDependent {
        typealias PointerType = Pointer
        // *offset was originally 64-bit on some x86_64 platforms.
        // We read and write only 32 bits of it.
        // Some metadata provides all 64 bits. This is harmless for unsigned
        // little-endian values.
        // Some code uses all 64 bits. class_addIvar() over-allocates the
        // offset for their benefit.

        var offset: UInt32
        var name: PointerType
        var type: PointerType
        // alignment is sometimes -1; use alignment() instead
        var alignment_raw: UInt32
        var size: UInt32
    }

    struct property_t<Pointer: UnsignedInteger>: ArchitectureDependent {
        typealias PointerType = Pointer

        var name: PointerType
        var attributes: PointerType
    }

    struct entsize_list_tt {
        // entsize_list_tt does not depend on architecture
        var entsizeAndFlags: UInt32
        var count: UInt32
        // var first:Element
    }

    struct category_t<Pointer: UnsignedInteger>: ArchitectureDependent {
        typealias PointerType = Pointer

        var name: PointerType
        var cls: PointerType
        var instanceMethods: PointerType
        var classMethods: PointerType
        var protocols: PointerType
        var instanceProperties: PointerType
        // Fields below this point are not always present on disk.
        var _classProperties: PointerType
    }

    struct protocol_t<Pointer: UnsignedInteger>: ArchitectureDependent {
        typealias PointerType = Pointer

        var isa: PointerType
        /// const char *mangledName;
        var name: PointerType

        /// struct protocol_list_t *protocols;
        var protocols: PointerType
        /// method_list_t *instanceMethods;
        var instanceMethods: PointerType
        /// method_list_t *classMethods;
        var classMethods: PointerType
        /// method_list_t *optionalInstanceMethods;
        var optionalInstanceMethods: PointerType
        /// method_list_t *optionalClassMethods;
        var optionalClassMethods: PointerType
        /// struct objc_property_list *instanceProperties;
        var instanceProperties: PointerType
    }
}
