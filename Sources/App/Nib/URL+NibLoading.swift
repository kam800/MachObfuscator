import Foundation

private let supportedNibFormats: [Nib.Type] = [
    NibPlist.self,
    NibArchive.self,
]

extension URL {
    func loadNib() -> Nib {
        guard let supportedNibFormat = supportedNibFormats.first(where: {
            $0.canLoad(from: self)
        }) else {
            fatalError("unsupported NIB format in \(self)")
        }
        return supportedNibFormat.load(from: self)
    }
}
