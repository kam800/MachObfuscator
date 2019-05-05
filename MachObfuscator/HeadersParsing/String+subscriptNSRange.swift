import Foundation

extension String {
    subscript(nsRange: NSRange) -> String {
        let range = Range(nsRange, in: self)!
        return String(self[range])
    }
}
