import Foundation

extension String {
    var asURL: URL {
        return URL(fileURLWithPath: self)
    }
}
