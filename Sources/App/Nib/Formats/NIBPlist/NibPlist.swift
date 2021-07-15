import Foundation

struct NibPlist {
    var url: URL
    var format: PropertyListSerialization.PropertyListFormat
    var contents: [String: Any]
}
