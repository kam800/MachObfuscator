import Foundation

// TODO: caching mach loader
class SimpleImageLoader {
    func load(forURL url: URL) throws -> Image {
        let data = try Data(contentsOf: url)
        return try Image(data: data, url: url)
    }
}
