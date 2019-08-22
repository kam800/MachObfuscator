import Foundation

class Obfuscator {
    private let directoryURL: URL

    private let mangler: SymbolMangling

    private let options: Options

    init(directoryURL: URL, mangler: SymbolMangling, options: Options) {
        self.directoryURL = directoryURL
        self.mangler = mangler
        self.options = options
    }

    func run(loader: ImageLoader & SymbolsSourceLoader & DependencyNodeLoader = SimpleImageLoader(),
             sourceSymbolsLoader: SourceSymbolsLoader = SimpleSourceSymbolsLoader()) {
        LOGGER.info("Will obfuscate \(directoryURL)")

        LOGGER.info("Looking for dependencies...")
        let paths = time(withTag: "Looking for dependencies") {
            ObfuscationPaths.forAllExecutables(inDirectory: directoryURL,
                                               dependencyNodeLoader: loader,
                                               obfuscableFilesFilter: options.obfuscableFilesFilter,
                                               withDependencies: options.analyzeDependencies)
        }
        LOGGER.info("\(paths.obfuscableImages.count) obfuscable images")
        LOGGER.debug("Obfuscable images:")
        paths.obfuscableImages.forEach { u in LOGGER.debug(u.absoluteString) }
        LOGGER.info("\(paths.nibs.count) obfuscable NIBs")

        LOGGER.info("Collecting symbols...")

        let symbols = time(withTag: "Build obfuscation symbols") {
            ObfuscationSymbols.buildFor(obfuscationPaths: paths,
                                        loader: loader,
                                        sourceSymbolsLoader: sourceSymbolsLoader,
                                        skippedSymbolsSources: options.skippedSymbolsSources,
                                        objcOptions: options.objcOptions)
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
