import Foundation

extension Sequence where Element: Hashable {
    var uniq: Set<Element> {
        return Set(self)
    }
}
