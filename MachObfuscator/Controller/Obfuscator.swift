import Foundation

class Obfuscator {
    private let directoryOrFileURL: URL
    private let isDirectory: Bool

    private let mangler: SymbolMangling

    private let options: Options

    init(directoryOrFileURL: URL, mangler: SymbolMangling, options: Options) {
        var isDir: ObjCBool = false
        guard FileManager.default.fileExists(atPath: directoryOrFileURL.path, isDirectory: &isDir) else {
            fatalError("'\(directoryOrFileURL.path)' does not exist")
        }
        self.directoryOrFileURL = directoryOrFileURL
        isDirectory = isDir.boolValue

        self.mangler = mangler
        self.options = options
    }

    func run(loader: ImageLoader & SymbolsSourceLoader & DependencyNodeLoader = SimpleImageLoader(),
             sourceSymbolsLoader: ObjectSymbolsLoader = SimpleSourceSymbolsLoader(),
             symbolListLoader: ObjectSymbolsLoader = TextFileSymbolListLoader()) {
        LOGGER.info("Will obfuscate \(directoryOrFileURL)")

        LOGGER.info("Looking for dependencies...")
        let paths = time(withTag: "Looking for dependencies") { () -> ObfuscationPaths in
            if isDirectory {
                return ObfuscationPaths.forAllExecutables(inDirectory: directoryOrFileURL,
                                                          dependencyNodeLoader: loader,
                                                          obfuscableFilesFilter: options.obfuscableFilesFilter,
                                                          withDependencies: options.analyzeDependencies)
            } else {
                return ObfuscationPaths.forExecutable(machOFile: directoryOrFileURL,
                                                      dependencyNodeLoader: loader,
                                                      obfuscableFilesFilter: options.obfuscableFilesFilter,
                                                      withDependencies: options.analyzeDependencies)
            }
        }
        LOGGER.info("\(paths.obfuscableImages.count) obfuscable images")
        LOGGER.debug("Obfuscable images:")
        paths.obfuscableImages.forEach { u in LOGGER.debug(u.absoluteString) }
        LOGGER.info("\(paths.nibs.count) obfuscable NIBs")

        LOGGER.info("Collecting symbols...")

        let symbols: ObfuscationSymbols = time(withTag: "Build obfuscation symbols") {
            autoreleasepool {
                let skippedSymbols = [
                    ObjectSymbols.blacklist(skippedSymbolsSources: options.skippedSymbolsSources,
                                            sourceSymbolsLoader: sourceSymbolsLoader),
                    ObjectSymbols.blacklist(skippedSymbolsLists: options.skippedSymbolsLists,
                                            symbolsListLoader: symbolListLoader),
                ].flatten()
                return ObfuscationSymbols.buildFor(obfuscationPaths: paths,
                                                   loader: loader,
                                                   sourceSymbolsLoader: sourceSymbolsLoader,
                                                   skippedSymbols: skippedSymbols,
                                                   objcOptions: options.objcOptions)
            }
        }
        LOGGER.info("\(symbols.whitelist.selectors.count) obfuscable selectors")
        LOGGER.info("\(symbols.whitelist.classes.count) obfuscable classes")
        LOGGER.info("\(symbols.blacklist.selectors.count) unobfuscable selectors")
        LOGGER.info("\(symbols.blacklist.classes.count) unobfuscable classes")

        LOGGER.info("Mangling symbols...")
        let manglingMap = mangler.mangleSymbols(symbols)
        LOGGER.info("\(manglingMap.selectors.count) mangled selectors")
        LOGGER.info("\(manglingMap.classNames.count) mangled classes")

        if options.swiftReflectionObfuscation {
            LOGGER.info("Will obfuscate Swift reflection sections")
        }
        if options.eraseMethType {
            LOGGER.info("Will erase methType sections")
        }

        var savable: [Savable] = []

        for obfuscableImage in paths.obfuscableImages {
            LOGGER.info("Obfuscating \(obfuscableImage)")
            var image: Image = try! loader.load(forURL: obfuscableImage)

            if options.dumpMetadata {
                image.dumpMetadata()
            }

            image.replaceSymbols(withMap: manglingMap, paths: paths)

            if options.eraseSymtab {
                image.eraseSymtab()
            } else {
                LOGGER.warn("Leaving SYMTAB unobfuscated")
            }

            // Some __cstrings operations
            image.replaceCstrings(mapping: options.cstringsReplacements)
            image.eraseFilePaths(options.sourceFileNamesPrefixes, usingReplacement: options.sourceFileNamesReplacement)

            if options.swiftReflectionObfuscation {
                image.eraseSwiftReflectiveSections()
            }
            if options.eraseMethType {
                image.eraseMethTypeSection()
            }
            for sectionDef in options.eraseSections {
                image.eraseSection(sectionDef.sectionName, segment: sectionDef.segmentName)
            }

            savable.append(image)
        }

        for nibPath in paths.nibs {
            LOGGER.info("Obfuscating \(nibPath)")
            var nib = nibPath.loadNib()
            nib.modifyClassNames(withMapping: manglingMap.classNames)
            nib.modifySelectors(withMapping: manglingMap.selectors)
            savable.append(nib)
        }

        if options.dryrun {
            LOGGER.warn("Running in dry run mode - will not update files")
        } else {
            LOGGER.info("Saving all the files in place...")
            savable.forEach {
                $0.save()
            }
        }

        LOGGER.info("BYE")
    }
}
