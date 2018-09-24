import Foundation

extension DependencyNodeLoader {
    func isMachOExecutable(atURL url: URL) -> Bool {
        do {
            let nodes = try load(forURL: url)
            return nodes.contains(where: { $0.isExecutable })
        } catch {
            return false
        }
    }
}
