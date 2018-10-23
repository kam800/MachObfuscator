import Foundation

class Obfuscator {
    private let directoryURL: URL
    private let mangler: SymbolMangling

    init(directoryURL: URL, mangler: SymbolMangling) {
        self.directoryURL = directoryURL
        self.mangler = mangler
    }

    func run(loader: ImageLoader & SymbolsSourceLoader & DependencyNodeLoader = SimpleImageLoader()) {
        LOGGER.info("Will obfuscate \(directoryURL)")

        LOGGER.info("Looking for dependencies...")
        let paths = ObfuscationPaths.forAllExecutablesWithDependencies(inDirectory: directoryURL, dependencyNodeLoader: loader)
        LOGGER.info("\(paths.obfuscableImages.count) obfuscable images")
        LOGGER.info("\(paths.nibs.count) obfuscable NIBs")

        LOGGER.info("Collecting symbols...")
        let symbols = ObfuscationSymbols.buildFor(obfuscationPaths: paths, loader: loader)
        LOGGER.info("\(symbols.whitelist.selectors.count) obfuscable selectors")
        LOGGER.info("\(symbols.whitelist.classes.count) obfuscable classes")
        LOGGER.info("\(symbols.blacklist.selectors.count) unobfuscable selectors")
        LOGGER.info("\(symbols.blacklist.classes.count) unobfuscable classes")

        LOGGER.info("Mangling symbols...")
        let manglingMap = mangler.mangleSymbols(symbols)
        LOGGER.info("\(manglingMap.selectors.count) mangled selectors")
        LOGGER.info("\(manglingMap.classNames.count) mangled classes")

        var savable: [Savable] = []

        for obfuscableImage in paths.obfuscableImages {
            LOGGER.info("Obfuscating \(obfuscableImage)")
            var image: Image = try! loader.load(forURL: obfuscableImage)
            image.replaceSymbols(withMap: manglingMap, paths: paths)
            // TODO: add option
            image.eraseSymtab()
            // TODO: add option
            image.eraseSwiftReflectiveSections()
            savable.append(image)
        }

        for nibPath in paths.nibs {
            LOGGER.info("Obfuscating \(nibPath)")
            var nib = nibPath.loadNib()
            nib.modifyClassNames(withMapping: manglingMap.classNames)
            nib.modifySelectors(withMapping: manglingMap.selectors)
            savable.append(nib)
        }

        LOGGER.info("Saving all the files in place...")
        savable.forEach {
            $0.save()
        }

        LOGGER.info("BYE")
    }
}
