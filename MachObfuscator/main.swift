import Foundation

private func main() {
    let options = Options.fromCommandLine()
    guard !options.help, let manglerType = options.manglerType, let appDirectoryOrFile = options.appDirectoryOrFile else {
        print(Options.usage)
        return
    }

    LOGGER = SoutLogger(options: options)
    let mangler = manglerType.resolveMangler(machOViewDoomEnabled: options.machOViewDoom)
    let obfuscator = Obfuscator(directoryOrFileURL: appDirectoryOrFile,
                                mangler: mangler,
                                options: options)
    obfuscator.run()
}

main()
