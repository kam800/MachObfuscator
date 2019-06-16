import Foundation

private func main() {
    let options = Options.fromCommandLine()
    guard !options.help, let manglerType = options.manglerType, let appDirectory = options.appDirectory else {
        print(Options.usage)
        return
    }

    guard FileManager.default.fileExists(atURL: appDirectory) else {
        print("'\(appDirectory.path)' does not exist")
        return
    }

    LOGGER = SoutLogger(options: options)
    let mangler = manglerType.resolveMangler(machOViewDoomEnabled: options.machOViewDoom)
    let obfuscator = Obfuscator(directoryURL: appDirectory,
                                mangler: mangler,
                                methTypeObfuscation: options.methTypeObfuscation,
                                swiftReflectionObfuscation: options.swiftReflectionObfuscation)
    obfuscator.run()
}

main()
