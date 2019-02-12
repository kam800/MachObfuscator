import Foundation

private func main() {
    let options = Options.fromCommandLine()
    guard !options.help, let manglerType = options.manglerType, let appDirectory = options.appDirectory else {
        return
    }

    LOGGER = SoutLogger(options: options)
    let mangler = manglerType.resolveMangler(machOViewDoomEnabled: options.machOViewDoom)
    let obfuscator = Obfuscator(directoryURL: appDirectory, mangler: mangler)
    print(Options.usage)
    obfuscator.run()
}

main()
