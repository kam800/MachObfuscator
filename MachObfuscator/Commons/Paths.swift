import Foundation

enum Paths {
    static let separator: Character = "/"

    private static func xcode_select() -> String? {
        let task = Process()

        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcode-select")
        task.arguments = ["--print-path"]
        let outputPipe = Pipe()
        task.standardOutput = outputPipe
        try! task.run()
        task.waitUntilExit()
        guard task.terminationStatus == 0 else {
            LOGGER.warn("Unable to invoke xcode-select")
            return nil
        }

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(decoding: outputData, as: UTF8.self)
        let path = output.trimmingCharacters(in: .newlines)

        // Test just in case, protects also against unexpected output
        guard FileManager.default.fileExists(atPath: path) else {
            LOGGER.warn("xcode-select returned non-existing path: \(path)")
            return nil
        }

        return path
    }

    static let xcodeRoot: String = {
        let root = xcode_select() ??
            // Default value if xcode-select fails
            "/Applications/Xcode.app/Contents/Developer"

        LOGGER.info("Determined Xcode root directory: \(root)")
        return root
    }()

    static let macosFrameworksRoot: String = xcodeRoot + "/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk"
    static let iosFrameworksRoot: String = xcodeRoot + "/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk"

    static let iosRuntimeRoot: String = {
        guard let iosRoot = possibleIosRuntimeRoots.first(where: FileManager.default.fileExists(atPath:)) else {
            fatalError("Could not find iOS runtime root. Make sure you have Xcode (10/11) installed.")
        }
        return iosRoot
    }()

    private static let possibleIosRuntimeRoots: [String] = [
        // Xcode 10
        xcodeRoot + "/Platforms/iPhoneOS.platform/"
            + "Developer/Library/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot",
        // Xcode 11
        xcodeRoot + "/Platforms/iPhoneOS.platform/"
            + "Library/Developer/CoreSimulator/Profiles/Runtimes/iOS.simruntime/Contents/Resources/RuntimeRoot",
    ]
}
