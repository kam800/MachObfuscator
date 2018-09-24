import Foundation

extension NibPlist {
    private static let magicBytes: [UInt8] = [UInt8]("bplist00".utf8)

    static func canLoad(from url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not read \(url)")
        }
        return data.starts(with: magicBytes)
    }

    static func load(from url: URL) -> Nib {
        let data = try! Data(contentsOf: url)
        var format: PropertyListSerialization.PropertyListFormat = .binary
        let nibObject = try! PropertyListSerialization.propertyList(from: data, options: [], format: &format)
        let nib = nibObject as! [String: Any]
        return NibPlist(url: url, format: format, contents: nib)
    }
}
