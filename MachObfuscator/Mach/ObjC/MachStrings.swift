//
//  Mach+Strings.swift
//  MachObfuscator
//

import Foundation

protocol ContainedInData {
    // associatedtype ValueType
    init(value: String, range: Range<Int>)
    var value: String { get }
    var range: Range<Int> { get }
}

class StringInData: ContainedInData, CustomStringConvertible {
    //typealias ValueType = String
    let value: String
    let range: Range<Int>
    required init(value: String, range: Range<Int>) {
        precondition(value.utf8.count == range.count)

        self.value = value
        self.range = range
    }

    var description: String { return "'\(value)'[\(range)]" }

    static let Empty = StringInData(value: "", range: 0 ..< 0)
}

/// Class/protocol/etc name class in objc class definition that can also contain names of Swift types that are visible from ObjC
class MangledObjcClassNameInData: StringInData {
    /// Checks if this is swift name.
    /// It looks like for Swift classes it always start with "_Tt" and is mangled, where plain ObjC classes are not mangled
    var isSwiftName: Bool {
        return value.starts(with: "_Tt")
    }
}

extension Data {
    func getCString<R>(atOffset offset: Int) -> R where R: ContainedInData {
        let value = getCString(atOffset: offset)
        let range = offset ..< offset + value.utf8.count
        return R(value: value, range: range)
    }
}
