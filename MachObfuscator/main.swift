import Foundation

private func main() {
    let options = Options.fromCommandLine()
    guard !options.help,
        let appDirectory = options.appDirectory,
        let mangler = SymbolManglers.mangler(byKey: options.manglerKey) else {
        return
    }
    LOGGER = SoutLogger(options: options)
    let obfuscator = Obfuscator(directoryURL: appDirectory, mangler: mangler)
    print(Options.usage)
    obfuscator.run()
}

main()
