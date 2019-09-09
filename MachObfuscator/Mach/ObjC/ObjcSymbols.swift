//
//  ObjcSymbols.swift
//  MachObfuscator
//

import Foundation

/// These protocols provide architecture independent and quite rich interface
/// for accessing ObjC metadata.

protocol ObjcIvar {
    var name: PlainStringInData { get }
    var type: PlainStringInData { get }
}

protocol ObjcProperty {
    var name: PlainStringInData { get }
    var attributes: PlainStringInData { get }
}

extension ObjcProperty {
    var isDynamic: Bool {
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
        return attributes.value.split(separator: ",").contains("D")
    }
}

protocol ObjcMethod {
    var name: PlainStringInData { get }
    var methType: PlainStringInData { get }
}

protocol ObjcClass {
    var ivarLayout: PlainStringInData? { get }
    var name: MangledObjcClassNameInData { get }
    var ivars: [ObjcIvar] { get }
    var methods: [ObjcMethod] { get }
    var properties: [ObjcProperty] { get }
}

protocol ObjcCategory {
    var name: MangledObjcClassNameInData { get }
    /// Class to which this category is related
    var cls: ObjcClass? { get }
    var methods: [ObjcMethod] { get }
    var properties: [ObjcProperty] { get }
}

protocol ObjcProtocol {
    var name: MangledObjcClassNameInData { get }
    var methods: [ObjcMethod] { get }
    var properties: [ObjcProperty] { get }
}
