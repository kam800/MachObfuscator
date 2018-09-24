import Foundation

// TODO: Savable protocol should be moved to some commons?
protocol Nib: Savable {
    static func canLoad(from url: URL) -> Bool
    static func load(from url: URL) -> Nib

    var selectors: [String] { get }
    var classNames: [String] { get }

    mutating func modifySelectors(withMapping map: [String: String])
    mutating func modifyClassNames(withMapping map: [String: String])

    func save()
}
