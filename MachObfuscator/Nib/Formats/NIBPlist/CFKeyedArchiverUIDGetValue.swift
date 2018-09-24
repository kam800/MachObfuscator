import Foundation

// Based on https://gist.github.com/NSProgrammer/8c2ce755d15777e62079788a7d788394
//
// CFUUID has a very nice feature in that it's structure
// is always the CFRuntimeBase struct (which we don't have access to)
// followed by a UUID in bytes.
// By simply traversing the CFUUID structs byte layout until we find
// the matching UUID bytes, we can determine the canonical size
// of the CFRuntimeBase at runtime!
// This is crucial since CFRuntimeBase is not guaranteed to stay
// the same size for any given OS release, and runtime inspection is
// necessary.

private var CFRuntimeBaseSize: Int = calculateCFRuntimeBaseSize()

private func calculateCFRuntimeBaseSize() -> Int {
    var uuidRef = CFUUIDCreate(nil)!
    var bytes = CFUUIDGetUUIDBytes(uuidRef)
    let bytesCount = withUnsafeBytes(of: &bytes) { ptr in
        return ptr.count
    }
    let bytesArray: [UInt8] = withUnsafePointer(to: &bytes) { ptr in
        return ptr.getStructs(count: bytesCount)
    }
    let index: Int? =
        withUnsafePointer(to: &uuidRef) { ptr in
            return ptr.withMemoryRebound(to: UnsafePointer<UInt8>.self,
                                         capacity: 1) { ptr in
                ptr.pointee.withMemoryRebound(to: UInt8.self,
                                              capacity: bytesCount * 4) { ptr in
                    return (0 ..< bytesCount * 3).first(where: { offset in
                        let bytesAtCuror: [UInt8] = ptr.advanced(by: offset).getStructs(count: bytesCount)
                        return bytesAtCuror == bytesArray
                    })
                }
            }
        }

    return index!
}

// Based on https://opensource.apple.com/source/CF/CF-368/Parsing.subproj/CFBinaryPList.c.auto.html
//
// struct __CFKeyedArchiverUID {
//   CFRuntimeBase _base;
//   uint32_t _value;
// };

func CFKeyedArchiverUIDGetValue(_ uid: Any) -> Int {
    var mutableUid = uid
    return withUnsafePointer(to: &mutableUid) { ptr in
        ptr.withMemoryRebound(to: UnsafePointer<UInt8>.self, capacity: 1) { ptr in
            return ptr.pointee.advanced(by: CFRuntimeBaseSize).withMemoryRebound(to: UInt32.self, capacity: 1, { ptr in
                Int(ptr.pointee)
            })
        }
    }
}
