import Foundation

extension Data {
    mutating func nullify(range: Range<Int>) {
        let nullReplacement = Data(repeating: 0, count: range.count)
        replaceSubrange(range, with: nullReplacement)
    }
}
