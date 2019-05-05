import Foundation

extension Image {
    mutating func replaceSymbols(withMap map: SymbolManglingMap, paths: ObfuscationPaths) {
        let imageUrl = url
        updateMachs { $0.replaceSymbols(withMap: map, imageURL: imageUrl, paths: paths) }
    }
}

private extension Mach {
    mutating func replaceSymbols(withMap map: SymbolManglingMap, imageURL: URL, paths: ObfuscationPaths) {
        if let methNameSection = objcMethNameSection {
            data.replaceStrings(inRange: methNameSection.range.intRange, withMapping: map.selectors)
        }
        if let classNameSection = objcClassNameSection {
            data.replaceStrings(inRange: classNameSection.range.intRange, withMapping: map.classNames)
        }

        if let (_, obfuscatedTrie) = map
            .exportTrieObfuscationMap[imageURL]?[cpu.asCpuId] {
            for obfuscatedNode in obfuscatedTrie.flatNodes {
                data.replaceBytes(inRange: obfuscatedNode.labelRange.intRange, withBytes: obfuscatedNode.label)
            }
        } else {
            fatalError()
        }

        if let importStack = importStack,
            let resolvedDylibsMap = paths.resolvedDylibMapPerImageURL[imageURL] {
            let resolvedDylibs = dylibs.map { resolvedDylibsMap[$0] }
            let obfuscatedSymbolPerUnobfuscatedSymbolPerImageURL: [URL: [String: String]] =
                map.exportTrieObfuscationMap.mapValues {
                    guard let (unobfuscatedTrie, obfuscatedTrie) = $0[cpu.asCpuId] else {
                        return [:]
                    }
                    let unobfuscatedObfuscatedExportedLabelPairs =
                        zip(unobfuscatedTrie.exportedLabelStrings,
                            obfuscatedTrie.exportedLabelStrings)
                    return Dictionary(uniqueKeysWithValues: unobfuscatedObfuscatedExportedLabelPairs)
                }
            for importEntry in importStack where importEntry.dylibOrdinal > 0 {
                let dylibIndex = importEntry.dylibOrdinal - 1
                if let dylibURL = resolvedDylibs[dylibIndex],
                    let obfuscatedSymbolPerUnobfuscatedSymbol =
                    obfuscatedSymbolPerUnobfuscatedSymbolPerImageURL[dylibURL],
                    let obfuscatedSymbolString = obfuscatedSymbolPerUnobfuscatedSymbol[importEntry.symbolString] {
                    let obfuscatedSymbol = [UInt8](obfuscatedSymbolString.utf8)
                    data.replaceBytes(inRange: importEntry.symbolRange.intRange, withBytes: obfuscatedSymbol)
                }
            }
        } else {
            fatalError("Didn't resolve dylibs for '\(imageURL)'. Probably a bug.")
        }

        if let symtab = symtab {
            data.replaceBytes(inRange: symtab.stringTableRange.intRange, withBytes: [UInt8](repeating: 0, count: symtab.stringTableRange.count))
        }
    }
}
