import Foundation

extension URL {
    func contains(_ other: URL) -> Bool {
        precondition(isFileURL)
        precondition(other.isFileURL)
        let c1 = pathComponents
        let c2 = other.pathComponents
        return c1.count <= c2.count
            && zip(c1, c2).first(where: !=) == nil
    }
}
