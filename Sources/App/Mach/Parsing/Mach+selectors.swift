import Foundation

extension Mach {
    // See `sel_init` function in https://opensource.apple.com/source/objc4/objc4-750.1/runtime/objc-sel.mm.auto.html
    // These selectors are usually loaded from libobjc.A.dylib and blacklisted as system selectors,
    // this list is important only in case of using the `xx-no-analyze-dependencies`
    static var libobjcSelectors: Set<String> { return [
        "load",
        "initialize",
        "resolveInstanceMethod:",
        "resolveClassMethod:",
        ".cxx_construct",
        ".cxx_destruct",
        "retain",
        "release",
        "autorelease",
        "retainCount",
        "alloc",
        "allocWithZone:",
        "dealloc",
        "copy",
        "new",
        "forwardInvocation:",
        "_tryRetain",
        "_isDeallocating",
        "retainWeakReference",
        "allowsWeakReference",
    ]
    }

    var selectors: [String] {
        guard let methNameSection = objcMethNameSection,
            !methNameSection.range.isEmpty
        else { return [] }
        let methodNamesData = data.subdata(in: methNameSection.range.intRange)
        return methodNamesData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }
}
