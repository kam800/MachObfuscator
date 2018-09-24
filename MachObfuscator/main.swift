import Foundation

private func main() {
    let options = Options.fromCommandLine()
    guard !options.help,
        let appDirectory = options.appDirectory,
        let mangler = SymbolManglers.mangler(byKey: options.manglerKey) else {
        print(Options.usage)
        return
    }
    LOGGER = SoutLogger(options: options)
    let obfuscator = Obfuscator(directoryURL: appDirectory, mangler: mangler)
    obfuscator.run()
}

main()
