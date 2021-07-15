import Foundation

protocol DependencyNodeLoader {
    func load(forURL url: URL) throws -> [DependencyNode]
}
