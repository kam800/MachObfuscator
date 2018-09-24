import Foundation

extension NibArchive {
    func save() {
        try! data.write(to: url)
    }
}
