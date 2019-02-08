import Foundation

private func main() {
    let options = Options.fromCommandLine()
    guard !options.help,
        let appDirectory = options.appDirectory,
        let manglerType = SymbolManglers(rawValue: options.manglerKey) else {
        return
    }
    LOGGER = SoutLogger(options: options)
    print(options.machOViewDoom)
    let mangler = manglerType.resolveMangler(machOViewDoom: options.machOViewDoom)
    let obfuscator = Obfuscator(directoryURL: appDirectory, mangler: mangler)
    print(Options.usage)
    obfuscator.run()
}

main()
