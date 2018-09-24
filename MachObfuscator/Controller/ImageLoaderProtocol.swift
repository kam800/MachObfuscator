import Foundation

protocol ImageLoader {
    func load(forURL url: URL) throws -> Image
}
