import Foundation

private let singleLineCommentExpr = try! NSRegularExpression(pattern: "^//.*$", options: [.anchorsMatchLines])
private let multilineCommentExpr = try! NSRegularExpression(pattern: "/\\*.*?\\*/", options: [.anchorsMatchLines, .dotMatchesLineSeparators])

extension String {
    var withoutComments: String {
        return withoutOccurences(of: singleLineCommentExpr)
            .withoutOccurences(of: multilineCommentExpr)
    }

    private func withoutOccurences(of regex: NSRegularExpression) -> String {
        let fullRange = NSRange(location: 0, length: count)
        return regex
            .matches(in: self, options: [], range: fullRange)
            .map { $0.range }
            .reversed()
            .reduce(into: self) { str, range -> Void in
                let r = Range(range, in: str)!
                str.removeSubrange(r)
            }
    }
}
