import Foundation

extension DependencyNodeLoader {
    func isMachOExecutable(atURL url: URL) -> Bool {
        return autoreleasepool {
            do {
                let nodes = try load(forURL: url)
                return nodes.contains(where: { $0.isExecutable })
            } catch {
                return false
            }
        }
    }
}
