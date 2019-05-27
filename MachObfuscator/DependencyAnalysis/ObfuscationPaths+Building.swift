import Foundation

extension ObfuscationPaths {
    static func forAllExecutablesWithDependencies(inDirectory dir: URL, fileRepository: FileRepository = FileManager.default, dependencyNodeLoader: DependencyNodeLoader) -> ObfuscationPaths {
        var paths = ObfuscationPaths()
        // TODO: create better exclusion mechanism (with custom excludes and includes)
        paths.addAllExecutablesWithDependencies(inDirectory: dir,
                                                fileRepository: fileRepository,
                                                imageLoader: dependencyNodeLoader,
                                                obfuscableFilesFilter: defaultObfuscableFilesFilter(obfuscableDirectory: dir))
        return paths
    }

    private mutating func addAllExecutablesWithDependencies(inDirectory dir: URL, fileRepository: FileRepository, imageLoader: DependencyNodeLoader, obfuscableFilesFilter: ObfuscableFilesFilter) {
        let files = fileRepository.listFilesRecursively(atURL: dir)
        let executables = files.filter { imageLoader.isMachOExecutable(atURL: $0) }
        executables.forEach {
            addExecutableWithDependencies(executableURL: $0, limitingObfuscationToDirectory: dir, fileRepository: fileRepository, dependencyNodeLoader: imageLoader, obfuscableFilesFilter: obfuscableFilesFilter)
        }
        nibs.formUnion(files.filter { $0.pathExtension.lowercased() == "nib" })
    }

    private mutating func addExecutableWithDependencies(executableURL: URL,
                                                        limitingObfuscationToDirectory _: URL,
                                                        fileRepository: FileRepository,
                                                        dependencyNodeLoader: DependencyNodeLoader,
                                                        obfuscableFilesFilter: ObfuscableFilesFilter) {
        let executableDir = executableURL.deletingLastPathComponent()
        let rpathsAccumulator = RpathsAccumulator(executablePath: executableDir)
        var imagesQueue: [URL] = [executableURL]

        while let nextImageURL = imagesQueue.popLast() {
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
            let stillUntraversedDependencies =
                resolvedLocationPerDylibPath.values
                .uniq
                .subtracting(obfuscableImages)
                .subtracting(unobfuscableDependencies)
            imagesQueue.append(contentsOf: stillUntraversedDependencies.reversed())
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

private struct ObfuscableFilesFilter {
    let isObfuscable: (URL) -> Bool
}

private extension ObfuscableFilesFilter {
    func and(_ other: ObfuscableFilesFilter) -> ObfuscableFilesFilter {
        return ObfuscableFilesFilter { url in
            self.isObfuscable(url) && other.isObfuscable(url)
        }
    }
}

private func defaultObfuscableFilesFilter(obfuscableDirectory: URL) -> ObfuscableFilesFilter {
    // > Swift apps no longer include dynamically linked libraries
    // > for the Swift standard library and Swift SDK overlays in
    // > build variants for devices running iOS 12.2, watchOS 5.2,
    // > and tvOS 12.2.
    // -- https://developer.apple.com/documentation/xcode_release_notes/xcode_10_2_beta_release_notes/swift_5_release_notes_for_xcode_10_2_beta
    return onlyFiles(in: obfuscableDirectory).and(notSwiftLibrary)
}

private let notSwiftLibrary = ObfuscableFilesFilter { url in
    !url.lastPathComponent.starts(with: "libswift")
}

private func onlyFiles(in obfuscableDirectory: URL) -> ObfuscableFilesFilter {
    return ObfuscableFilesFilter { url in
        obfuscableDirectory.contains(url)
    }
}
