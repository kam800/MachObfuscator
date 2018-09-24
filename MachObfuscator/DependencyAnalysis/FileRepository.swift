import Foundation

protocol FileRepository {
    func listFilesRecursively(atURL url: URL) -> [URL]
    func fileExists(atURL url: URL) -> Bool
}

extension FileManager: FileRepository {
    func listFilesRecursively(atURL url: URL) -> [URL] {
        guard let enumerator = enumerator(at: url, includingPropertiesForKeys: [.isRegularFileKey]) else {
            fatalError("Could not enumerate files in \(url)")
        }
        return enumerator.compactMap { $0 as? URL }
            .map { $0.resolvingSymlinksInPath() }
            .filter { $0.isRegularFile }
    }

    func fileExists(atURL url: URL) -> Bool {
        return fileExists(atPath: url.path)
    }
}

private extension URL {
    var isRegularFile: Bool {
        do {
            let value = try resourceValues(forKeys: [.isRegularFileKey])
            return value.isRegularFile ?? false
        } catch {
            fatalError("Could not read \(self)")
        }
    }
}
