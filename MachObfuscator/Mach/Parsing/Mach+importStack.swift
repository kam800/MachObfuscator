import Foundation

extension Mach {
    var importStack: ImportStack? {
        guard let dyldInfo = dyldInfo else {
            return nil
        }
        var importStack = ImportStack()
        importStack.add(opcodesData: data, range: dyldInfo.bind.intRange, weakly: false)
        importStack.add(opcodesData: data, range: dyldInfo.weakBind.intRange, weakly: true)
        importStack.add(opcodesData: data, range: dyldInfo.lazyBind.intRange, weakly: false)
        importStack.resolveMissingDylibOrdinals()
        return importStack
    }
}
