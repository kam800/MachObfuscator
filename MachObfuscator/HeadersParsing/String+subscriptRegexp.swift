import Foundation

extension String {
    subscript(regexp: NSRegularExpression, group: Int) -> String? {
        let matchingRange = regexp
            .firstMatch(in: self)?
            .range(at: group)

        return matchingRange.flatMap { self[$0] }
    }
}
