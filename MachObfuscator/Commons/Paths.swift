import Foundation

enum Paths {
    static let separator: Character = "/"
    static let macosFrameworksRoot = "/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    static let iosFrameworksRoot = "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"

    static let iosRuntimeRoot: String = {
        guard let iosRoot = possibleIosRuntimeRoots.first(where: FileManager.default.fileExists(atPath:)) else {
            fatalError("Could not find iOS runtime root. Make sure you have Xcode (10/11) installed.")
        }
        return iosRoot
    }()

    private static let possibleIosRuntimeRoots: [String] = [
        // Xcode 10
        "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/"
            + "Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot",
        // Xcode 11
        "/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/"
            + "Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot",
    ]
}
