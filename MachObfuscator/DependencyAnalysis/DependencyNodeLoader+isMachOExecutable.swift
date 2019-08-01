import Foundation

extension DependencyNodeLoader {
    func isMachOFile(atURL url: URL) -> Bool {
        do {
            let nodes = try load(forURL: url)
            return !nodes.isEmpty
        } catch {
            return false
        }
    }

    func isMachOExecutable(atURL url: URL) -> Bool {
        do {
            let nodes = try load(forURL: url)
            return nodes.contains(where: { $0.isExecutable })
        } catch {
            return false
        }
    }
}
