import Foundation

extension ObfuscationPaths {
    static func forAllExecutablesWithDependencies(inDirectory dir: URL, fileRepository: FileRepository = FileManager.default, dependencyNodeLoader: DependencyNodeLoader) -> ObfuscationPaths {
        var paths = ObfuscationPaths()
        paths.addAllExecutablesWithDependencies(inDirectory: dir, fileRepository: fileRepository, imageLoader: dependencyNodeLoader)
        return paths
    }

    private mutating func addAllExecutablesWithDependencies(inDirectory dir: URL, fileRepository: FileRepository, imageLoader: DependencyNodeLoader) {
        let files = fileRepository.listFilesRecursively(atURL: dir)
        let executables = files.filter { imageLoader.isMachOExecutable(atURL: $0) }
        executables.forEach {
            addExecutableWithDependencies(executableURL: $0, limitingObfuscationToDirectory: dir, fileRepository: fileRepository, dependencyNodeLoader: imageLoader)
        }
        nibs.formUnion(files.filter { $0.pathExtension.lowercased() == "nib" })
    }

    private mutating func addExecutableWithDependencies(executableURL: URL,
                                                        limitingObfuscationToDirectory obfuscableDirectory: URL,
                                                        fileRepository: FileRepository,
                                                        dependencyNodeLoader: DependencyNodeLoader) {
        let executableDir = executableURL.deletingLastPathComponent()
        let rpathsAccumulator = RpathsAccumulator(executablePath: executableDir)
        var imagesQueue: [URL] = [executableURL]

        while let nextImageURL = imagesQueue.popLast() {
            // TODO: create better exclusion mechanism
            if obfuscableDirectory.contains(nextImageURL) && !nextImageURL.path.contains("libswift") {
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
            let stillUntraversedDependencies =
                resolvedLocationPerDylibPath.values
                .uniq
                .subtracting(obfuscableImages)
                .subtracting(unobfuscableDependencies)
            imagesQueue.append(contentsOf: stillUntraversedDependencies.reversed())
        }
    }
}
