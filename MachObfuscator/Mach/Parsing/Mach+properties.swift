import Foundation

extension Mach {
    // TODO: custom setter and getter names
    var dynamicPropertyNames: [String] {
        return properties
            .filter { $0.isDynamic }
            .map { $0.name.value }
    }

    private var properties: [ObjcProperty] {
        return classProperties + categoryProperties
    }

    private var classProperties: [ObjcProperty] {
        return objcClasses.flatMap { $0.properties }
    }

    private var categoryProperties: [ObjcProperty] {
        return objcCategories.flatMap { $0.properties }
    }
}

private extension ObjcProperty {
    var isDynamic: Bool {
        // https://developer.apple.com/library/archive/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
        return attributes.value.split(separator: ",").contains("D")
    }
}
