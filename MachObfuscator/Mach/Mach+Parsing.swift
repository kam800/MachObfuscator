import Foundation

extension Mach {
    var selectors: [String] {
        guard let methNameSection = objcMethNameSection
        else { return [] }
        let methodNamesData = data.subdata(in: methNameSection.range.intRange)
        return methodNamesData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }

    var classNames: [String] {
        guard let classNameSection = objcClassNameSection
        else { return [] }
        let classNamesData = data.subdata(in: classNameSection.range.intRange)
        return classNamesData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }

    var cstrings: [String] {
        guard let cstringSection = cstringSection
        else { return [] }
        let cstringData = data.subdata(in: cstringSection.range.intRange)
        return cstringData.split(separator: 0).compactMap { String(bytes: $0, encoding: .utf8) }
    }

    var exportedTrie: Trie? {
        guard let dyldInfo = dyldInfo else {
            return nil
        }
        return Trie(data: data, rootNodeOffset: Int(dyldInfo.exportRange.lowerBound))
    }

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
