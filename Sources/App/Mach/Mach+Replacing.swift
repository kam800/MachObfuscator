import Foundation

extension Image {
    mutating func replaceSymbols(withMap map: SymbolManglingMap, paths: ObfuscationPaths) {
        let imageUrl = url
        updateMachs { $0.replaceSymbols(withMap: map, imageURL: imageUrl, paths: paths) }
    }

    mutating func replaceCstrings(mapping: [String: String]) {
        updateMachs { $0.replaceCstrings(mapping: mapping) }
    }
}

private extension String {
    func replacing(of sourceString: String, precededBy: String, followedBy: String, with targetString: String) -> String {
        return replacingOccurrences(of: precededBy + sourceString + followedBy, with: precededBy + targetString + followedBy)
    }

    func replacing(of sourceString: String, surroundedByAny: [(String, String)], with targetString: String) -> String {
        return surroundedByAny.reduce(self) { (current, surroundedBy) -> String in
            current.replacing(of: sourceString, precededBy: surroundedBy.0, followedBy: surroundedBy.1, with: targetString)
        }
    }
}

private extension Mach {
    mutating func replaceSymbols(withMap map: SymbolManglingMap, imageURL: URL, paths: ObfuscationPaths) {
        // Obfuscate from more specific to less specific objects
        // When class name is not overwritten debugging other obfuscations is simpler.

        if let methTypeSection = objcMethTypeSection {
            data.replaceStrings(inRange: methTypeSection.range.intRange,
                                withMapping: MethTypeObfuscator(withMap: map).generateObfuscatedMethType(methType:))
        }

        if let methNameSection = objcMethNameSection {
            data.replaceStrings(inRange: methNameSection.range.intRange, withMapping: map.selectors)
        }

        // Obfuscate property types
        objcClasses.flatMap { $0.properties }.forEach { property in
            var attrs = property.attributeValues
            let typename = property.typeAttribute
            let newTypename = MethTypeObfuscator(withMap: map).generateObfuscatedMethType(methType: typename)
            if newTypename != typename {
                attrs[0] = newTypename
                let newAttrsString = attrs.joined(separator: ",")
                data.replaceRangeWithPadding(property.attributes.range, with: newAttrsString)
            }
        }

        classNamesInData.forEach { classNameInData in
            if let obfuscatedName = map.classNames[classNameInData.value] {
                data.replaceRangeWithPadding(classNameInData.range, with: obfuscatedName)
            }
        }

        if let (_, obfuscatedTrie) = map
            .exportTrieObfuscationMap[imageURL]?[cpu.asCpuId] {
            for obfuscatedNode in obfuscatedTrie.flatNodes {
                data.replaceBytes(inRange: obfuscatedNode.labelRange.intRange, withBytes: obfuscatedNode.label)
            }
        } else if hasBitCode {
            // LLVM-IR (Bitcode) images may not have export trie
            LOGGER.info("Image '\(imageURL)' contains bitcode for \(cpu). Not obfuscating export trie.")
        } else {
            fatalError()
        }

        let localImportStack = importStack
        if !localImportStack.isEmpty,
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
            for importEntry in localImportStack where importEntry.dylibOrdinal > 0 {
                let dylibIndex = importEntry.dylibOrdinal - 1
                if let dylibURL = resolvedDylibs[dylibIndex],
                    let obfuscatedSymbolPerUnobfuscatedSymbol =
                    obfuscatedSymbolPerUnobfuscatedSymbolPerImageURL[dylibURL],
                    let obfuscatedSymbolString = obfuscatedSymbolPerUnobfuscatedSymbol[importEntry.symbolString] {
                    let obfuscatedSymbol = [UInt8](obfuscatedSymbolString.utf8)
                    data.replaceBytes(inRange: importEntry.symbolRange.intRange, withBytes: obfuscatedSymbol)
                }
            }
        } else if hasBitCode {
            // LLVM-IR (Bitcode) images may not have import trie
            LOGGER.info("Image '\(imageURL)' contains bitcode for \(cpu). Not obfuscating import stack.")
        } else {
            fatalError("Didn't resolve dylibs for '\(imageURL)'. Probably a bug.")
        }
    }

    // Replace arbitrary CString
    mutating func replaceCstrings(mapping: [String: String]) {
        guard !mapping.isEmpty else {
            // nothing to do
            return
        }

        guard let cstrings = cstringSection else {
            return
        }

        data.replaceStrings(inRange: cstrings.range.intRange, withMapping: {
            let replacement = mapping[$0]!
            return replacement
        }, withFilter: {
            cstring in mapping[cstring] != nil
        })
    }
}

struct MethTypeObfuscator {
    private let typeMapping: [String: String]
    init(withMap map: SymbolManglingMap) {
        typeMapping = map.classNames
    }

    init(withMapping map: [String: String]) {
        typeMapping = map
    }

    // Generate obfuscated methtype from original one. If there is no matching obfuscation, returns input unchanged
    public func generateObfuscatedMethType(methType: String) -> String {
        // This is very naive and simple algorithm and not efficient at all.
        // Its main advantage is that it does not require parsing and generating methType strings
        // Class names seem to be always surrounded by some kind of special characters, like " or < and >
        let newMethType = typeMapping.reduce(methType) { (curResult, mapping) -> String in
            guard curResult.contains(mapping.key) else {
                // There is small possibility of match, so it better to search once in case of no-match
                // for the cost of searching one more time in case of match.
                // Note, that match in this check may be false-positive (only substring of identifer matches)
                // but that is no problem for this optimization.
                return curResult
            }
            return curResult.replacing(of: mapping.key, surroundedByAny: [("\"", "\""), ("(", ")"), ("[", "]"), ("<", ">"), ("{", "}")], with: mapping.value)
        }
        if newMethType != methType {
            LOGGER.debug("MethType obfuscation from \(methType) to \(newMethType)")
        }
        return newMethType
    }
}
