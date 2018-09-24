import Foundation

extension URL {
    private class MarkerClass {}

    static var fatIosExecutable: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SampleFatIosExecutable", withExtension: nil)!
    }

    static var machoMacExecutable: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SampleMachoMacExecutable", withExtension: nil)!
    }
}
