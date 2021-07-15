import Foundation

extension NSRegularExpression {
    func firstMatch(in string: String) -> NSTextCheckingResult? {
        return firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.count))
    }

    func matches(in string: String) -> [NSTextCheckingResult] {
        return matches(in: string, options: [], range: NSRange(location: 0, length: string.count))
    }
}
