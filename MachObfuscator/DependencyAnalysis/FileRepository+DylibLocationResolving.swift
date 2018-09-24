import Foundation

extension FileRepository {
    func resolvedDylibLocations(loader: URL, rpathsAccumulator: RpathsAccumulator, dependencyNodeLoader: DependencyNodeLoader) -> [String: URL] {
        let loaderPath = loader.deletingLastPathComponent()
        let nodes = try! dependencyNodeLoader.load(forURL: loader)
        nodes.forEach { node in
            rpathsAccumulator.add(rpaths: node.rpaths, loaderPath: loaderPath, platform: node.platform)
        }
        let dylibAndResolvedLocationPairs: [(String, URL)] = nodes.flatMap { node in
            node.dylibs.compactMap { dylibPath in
                guard let resolverDylibLocation = rpathsAccumulator.resolve(dylibEntry: dylibPath,
                                                                            loaderPath: loaderPath,
                                                                            platform: node.platform,
                                                                            fileRepository: self) else {
                    LOGGER.warn("Unable to resolve dylib path \(dylibPath)")
                    return nil
                }
                return (dylibPath, resolverDylibLocation)
            }
        }
        let resolvedLocationPerDylibPath = [String: URL](dylibAndResolvedLocationPairs,
                                                         uniquingKeysWith: { path1, path2 in
                                                             if path1 != path2 {
                                                                 fatalError("ambiguous resolved dylib locations in \(self)")
                                                             }
                                                             return path1
        })
        return resolvedLocationPerDylibPath
    }
}
