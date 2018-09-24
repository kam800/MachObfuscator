import Foundation

extension Mach: DependencyNode {
    var isExecutable: Bool {
        return type == .executable
    }
}

extension SimpleImageLoader: DependencyNodeLoader {
    func load(forURL url: URL) throws -> [DependencyNode] {
        return (try load(forURL: url) as Image).machs
    }
}
