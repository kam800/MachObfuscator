import Foundation

extension ObfuscationPaths {
    static func forAllExecutables(inDirectory dir: URL, fileRepository: FileRepository = FileManager.default, dependencyNodeLoader: DependencyNodeLoader, obfuscableFilesFilter: ObfuscableFilesFilter, withDependencies: Bool = true) -> ObfuscationPaths {
        var paths = ObfuscationPaths()
        paths.addAllExecutables(inDirectory: dir,
                                fileRepository: fileRepository,
                                imageLoader: dependencyNodeLoader,
                                obfuscableFilesFilter: obfuscableFilesFilter.and(ObfuscableFilesFilter.onlyFiles(in: dir)),
                                withDependencies: withDependencies)
        return paths
    }

    private mutating func addAllExecutables(inDirectory dir: URL, fileRepository: FileRepository, imageLoader: DependencyNodeLoader, obfuscableFilesFilter: ObfuscableFilesFilter, withDependencies: Bool = true) {
        let files = fileRepository.listFilesRecursively(atURL: dir)
        let executables = files.filter { imageLoader.isMachOExecutable(atURL: $0) }
        executables.forEach {
            addExecutable(executableURL: $0, limitingObfuscationToDirectory: dir, fileRepository: fileRepository, dependencyNodeLoader: imageLoader, obfuscableFilesFilter: obfuscableFilesFilter, withDependencies: withDependencies)
        }
        nibs.formUnion(files.filter { $0.pathExtension.lowercased() == "nib" })
    }

    private mutating func addExecutable(executableURL: URL,
                                        limitingObfuscationToDirectory _: URL,
                                        fileRepository: FileRepository,
                                        dependencyNodeLoader: DependencyNodeLoader,
                                        obfuscableFilesFilter: ObfuscableFilesFilter,
                                        withDependencies: Bool = true) {
        let executableDir = executableURL.deletingLastPathComponent()
        let rpathsAccumulator = RpathsAccumulator(executablePath: executableDir)
        var imagesQueue: [URL] = [executableURL]

        while let nextImageURL = imagesQueue.popLast() {
            // Data/NSData leaves much garbage in autoreleasepool that is not refereced and could be freed.
            // This pool is not released automatically in console app during application run time
            // and causes constant growth of memory usage.
            // Therefore release is triggered in critical moments - after processing of given binary file,
            // when its data should be no more needed (beware of leaving references to `Mach.data`).
            // See also https://medium.com/swift2go/autoreleasepool-uses-in-2019-swift-9e8fd7b1cd3f
            autoreleasepool {
                if obfuscableFilesFilter.isObfuscable(nextImageURL) {
                    obfuscableImages.insert(nextImageURL)
                } else {
                    unobfuscableDependencies.insert(nextImageURL)
                }
                let resolvedLocationPerDylibPath =
                    fileRepository.resolvedDylibLocations(loader: nextImageURL,
                                                          rpathsAccumulator: rpathsAccumulator,
                                                          dependencyNodeLoader: dependencyNodeLoader)
                if let previouslyResolvedLocationDylibPath = resolvedDylibMapPerImageURL[nextImageURL] {
                    if previouslyResolvedLocationDylibPath != resolvedLocationPerDylibPath {
                        fatalError("Image dylib locations already resolved for \(nextImageURL), subsequent resolution is different. This is unsupported in this version.")
                    }
                } else {
                    resolvedDylibMapPerImageURL[nextImageURL] = resolvedLocationPerDylibPath
                }
                if withDependencies {
                    let stillUntraversedDependencies =
                        resolvedLocationPerDylibPath.values
                        .uniq
                        .subtracting(obfuscableImages)
                        .subtracting(unobfuscableDependencies)

                    imagesQueue.append(contentsOf: stillUntraversedDependencies.reversed())
                }
            }
        }

        systemFrameworks = obfuscableImages
            .flatMap { imageURL -> [URL] in
                resolvedDylibMapPerImageURL[imageURL]?.keys.flatMap { dylibEntry -> [URL] in
                    fileRepository.resolvedSystemFrameworkLocations(dylibEntry: dylibEntry,
                                                                    referencingURL: imageURL,
                                                                    dependencyNodeLoader: dependencyNodeLoader)
                } ?? []
            }
            .uniq
    }
}
