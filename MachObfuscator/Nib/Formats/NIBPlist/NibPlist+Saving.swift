import Foundation

extension NibPlist {
    func save() {
        let data = try! PropertyListSerialization.data(fromPropertyList: contents, format: format, options: 0)
        try! data.write(to: url)
    }
}
