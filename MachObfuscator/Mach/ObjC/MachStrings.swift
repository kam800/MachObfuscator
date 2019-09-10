//
//  Mach+Strings.swift
//  MachObfuscator
//

import Foundation

protocol ContainedInData {
    associatedtype ValueType
    init(value: ValueType, range: Range<Int>)
    var value: ValueType { get }
    var range: Range<Int> { get }
}

extension CustomStringConvertible where Self: ContainedInData {
    var description: String { return "'\(value)'[\(range)]" }
}

struct PlainStringInData: ContainedInData, CustomStringConvertible {
    let value: String
    let range: Range<Int>

    init(value: String, range: Range<Int>) {
        precondition(value.utf8.count == range.count)

        self.value = value
        self.range = range
    }

    static let empty = PlainStringInData(value: "", range: 0 ..< 0)
}

/// Class/protocol/etc name class in objc class definition that can also contain names of Swift types that are visible from ObjC
struct MangledObjcClassNameInData: ContainedInData, CustomStringConvertible {
    let value: String
    let range: Range<Int>

    init(value: String, range: Range<Int>) {
        precondition(value.utf8.count == range.count)

        self.value = value
        self.range = range
    }
}

extension MangledObjcClassNameInData {
    /// Checks if this is Swift name.
    /// It looks like for Swift classes it always start with "_Tt" and is mangled, where plain ObjC classes are not mangled
    var isSwiftName: Bool {
        return value.starts(with: "_Tt")
    }
}

extension Data {
    func getCString<R>(atOffset offset: Int) -> R where R: ContainedInData, R.ValueType == String {
        let value = getCString(atOffset: offset)
        let range = offset ..< offset + value.utf8.count
        return R(value: value, range: range)
    }
}

extension Mach.Section {
    func contains<ContainedInDataType: ContainedInData>(data: ContainedInDataType) -> Bool {
        return range.intRange.overlaps(data.range)
    }
}
