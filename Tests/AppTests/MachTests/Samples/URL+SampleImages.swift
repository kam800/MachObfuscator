import Foundation

extension URL {
    private class MarkerClass {}

    static var fatIosExecutable: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SampleFatIosExecutable", withExtension: nil)!
    }

    static var machoMacExecutable: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SampleMachoMacExecutable", withExtension: nil)!
    }

    // To obtain this executable compile SampleMacApp with MACOSX_DEPLOYMENT_TARGET = 10.14
    static var machoMac10_14Executable: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SampleMachoMac10_14Executable", withExtension: nil)!
    }

    // To obtain this executable compile SampleIosApp with IPHONEOS_DEPLOYMENT_TARGET = 12.0
    static var machoIos12_0Executable: URL {
        return Bundle(for: MarkerClass.self).url(forResource: "SampleMachoIos12_0Executable", withExtension: nil)!
    }
}
