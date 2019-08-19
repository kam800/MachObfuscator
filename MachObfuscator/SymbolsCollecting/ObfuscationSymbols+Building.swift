import Foundation

extension ObfuscationSymbols {
    static func buildFor(obfuscationPaths: ObfuscationPaths,
                         loader: SymbolsSourceLoader,
                         sourceSymbolsLoader: SourceSymbolsLoader,
                         skippedSymbolsSources: [URL],
                         objcOptions: ObjcOptions = ObjcOptions()) -> ObfuscationSymbols {
        let systemSources = time(withTag: "systemSources") { try! obfuscationPaths.unobfuscableDependencies.flatMap { try loader.load(forURL: $0) } }

        let userSourcesPerPath = time(withTag: "userSources") { [URL: [SymbolsSource]](uniqueKeysWithValues: obfuscationPaths.obfuscableImages.map { ($0, try! loader.load(forURL: $0)) }) }
        let userSources = userSourcesPerPath.values.flatMap { $0 }

        let userSelectors = userSources.flatMap { $0.selectors }.uniq
        let userClasses = userSources.flatMap { $0.classNames }.uniq
        let userCStrings = userSources.flatMap { $0.cstrings }.uniq
        let userDynamicProperties = userSources.flatMap { $0.dynamicPropertyNames }.uniq
        let systemSelectors = systemSources.flatMap { $0.selectors }.uniq
        let systemClasses = systemSources.flatMap { $0.classNames }.uniq
        let systemCStrings = systemSources.flatMap { $0.cstrings }.uniq

        let systemHeaderSymbols = time(withTag: "systemHeaderSymbols") { obfuscationPaths.systemFrameworks
            .concurrentMap(sourceSymbolsLoader.forceLoad(forFrameworkURL:))
            .flatten()
        }

        let skippedSymbols = skippedSymbolsSources
            .map(sourceSymbolsLoader.forceLoad(forFrameworkURL:))
            .flatten()

        // TODO: Array(userCStrings) should be opt-in
        let blackListGetters: Set<String> =
            systemHeaderSymbols.selectors
            .union(systemSelectors)
            .union(systemCStrings)
            .union(userDynamicProperties)
            .union(userCStrings)
            .union(skippedSymbols.selectors)
        let blacklistSetters = blackListGetters.map { $0.asSetter }.uniq

        let blacklistedSelectorsByRegex = userSelectors.filter { selector in
            objcOptions.selectorsBlacklistRegex.contains(where: { regex in
                regex.firstMatch(in: selector) != nil
            })
        }
        let notFoundBlacklistedSelectors = Set(objcOptions.selectorsBlacklist).subtracting(userSelectors)
        if !notFoundBlacklistedSelectors.isEmpty {
            LOGGER.warn("Some selectors specified on blacklist were not found: \(notFoundBlacklistedSelectors)")
        }

        let blacklistSelectors = (Array(blackListGetters) + Array(blacklistSetters) + objcOptions.selectorsBlacklist + blacklistedSelectorsByRegex).uniq
        // TODO: Array(userCStrings) should be opt-in
        let blacklistClasses: Set<String> =
            systemHeaderSymbols.classNames
            .union(systemClasses)
            .union(systemCStrings)
            .union(userCStrings)
            .union(skippedSymbols.classNames)
        let whitelistSelectors = userSelectors.subtracting(blacklistSelectors)
        let whitelistClasses = userClasses.subtracting(blacklistClasses)

        let whitelistExportTriePerCpuIdPerURL: [URL: [CpuId: Trie]] =
            userSourcesPerPath.mapValues { symbolsSources in
                [CpuId: Trie](symbolsSources.map { ($0.cpu.asCpuId, $0.exportedTrie!) },
                              uniquingKeysWith: { _, _ in fatalError("Duplicated cpuId") })
            }

        let whiteList = ObjCSymbols(selectors: whitelistSelectors, classes: whitelistClasses)
        let blackList = ObjCSymbols(selectors: blacklistSelectors, classes: blacklistClasses)
        return ObfuscationSymbols(whitelist: whiteList, blacklist: blackList, exportTriesPerCpuIdPerURL: whitelistExportTriePerCpuIdPerURL)
    }
}

extension Image {
    var machPerOffset: [UInt64: Mach] {
        switch contents {
        case let .fat(fat):
            return [UInt64: Mach](fat.architectures.map { ($0.offset, $0.mach) },
                                  uniquingKeysWith: { _, _ in
                                      fatalError("Two architectures at the same offset. Programming error?")
            })
        case let .mach(mach):
            return [0: mach]
        }
    }
}

private extension String {
    var asSetter: String {
        guard count >= 1 else {
            return self
        }
        return "set\(capitalizedOnFirstLetter):"
    }
}

private extension SourceSymbolsLoader {
    func forceLoad(forFrameworkURL url: URL) -> SourceSymbols {
        do {
            LOGGER.info("Collecting symbols from \(url)")
            return try load(forFrameworkURL: url)
        } catch {
            fatalError("Error while reading symbols from path '\(url)': \(error)")
        }
    }
}
