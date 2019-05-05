import Foundation

extension ObfuscationSymbols {
    static func buildFor(obfuscationPaths: ObfuscationPaths,
                         loader: SymbolsSourceLoader,
                         headerLoader: HeaderSymbolsLoader) -> ObfuscationSymbols {
        let systemSources = try! obfuscationPaths.unobfuscableDependencies.flatMap { try loader.load(forURL: $0) }

        let userSourcesPerPath = [URL: [SymbolsSource]](uniqueKeysWithValues: obfuscationPaths.obfuscableImages.map { ($0, try! loader.load(forURL: $0)) })
        let userSources = userSourcesPerPath.values.flatMap { $0 }

        let userSelectors = userSources.flatMap { $0.selectors }.uniq
        let userClasses = userSources.flatMap { $0.classNames }.uniq
        let userCStrings = userSources.flatMap { $0.cstrings }.uniq
        let userDynamicProperties = userSources.flatMap { $0.dynamicPropertyNames }.uniq
        let systemSelectors = systemSources.flatMap { $0.selectors }.uniq
        let systemClasses = systemSources.flatMap { $0.classNames }.uniq
        let systemCStrings = systemSources.flatMap { $0.cstrings }.uniq

        let systemHeaderSymbols = obfuscationPaths
            .systemFrameworks
            .map { try! headerLoader.load(forFrameworkURL: $0) }
            .flatten()

        // TODO: Array(userCStrings) should be opt-in
        let blackListGetters =
            (Array(systemHeaderSymbols.selectors)
                + Array(systemSelectors)
                + Array(systemCStrings)
                + Array(userDynamicProperties)
                + Array(userCStrings)).uniq
        let blacklistSetters = blackListGetters.map { $0.asSetter }.uniq

        let blacklistSelectors = (Array(blackListGetters) + Array(blacklistSetters)).uniq
        // TODO: Array(userCStrings) should be opt-in
        let blacklistClasses =
            (Array(systemHeaderSymbols.classNames)
                + Array(systemClasses)
                + Array(systemCStrings)
                + Array(userCStrings)).uniq
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
