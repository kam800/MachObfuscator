import Foundation

extension Mach {
    // Only ObjC class names
    var classNamesInData: [MangledObjcClassNameInData] {
        // TODO: should category names be treated as classnames? Currently they are because they used to be,
        // but it may be not the best solution.
        return (objcClasses.map { $0.name } + objcProtocols.map { $0.name }).filter { !$0.isSwiftName } + pureObjcCategoryNames
    }

    // Only ObjC class names
    var classNames: [String] {
        return classNamesInData.map { $0.value }
    }

    private var pureObjcCategoryNames: [MangledObjcClassNameInData] {
        return objcCategories.map { $0.name }.filter(isPureObjCCategory(_:))
    }

    func isPureObjCCategory(_ name: MangledObjcClassNameInData) -> Bool {
        return objcClassNameSection?.contains(data: name) ?? false
    }
}
