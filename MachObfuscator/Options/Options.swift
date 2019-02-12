import Foundation

struct Options {
    var help: Bool
    var quiet: Bool
    var verbose: Bool
    var methTypeObfuscation: Bool
    var machOViewDoom: Bool
    var manglerType: SymbolManglers?
    var appDirectory: URL?
}

extension Options {
    typealias UnsafeArgv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>

    static func fromCommandLine() -> Options {
        return self.init(argc: CommandLine.argc,
                         unsafeArgv: CommandLine.unsafeArgv,
                         argv: CommandLine.arguments)
    }

    init(argc: Int32, unsafeArgv: UnsafeArgv, argv: [String]) {
        optreset = 1
        var help = false
        var quiet = false
        var verbose = false
        var machOViewDoom = false
        var methTypeObfuscation = false
        var manglerKey = SymbolManglers.defaultManglerKey
        while case let option = getopt(argc, unsafeArgv, "qvhtDm:"), option != -1 {
            let char = UnicodeScalar(CUnsignedChar(option))
            switch char {
            case "q":
                quiet = true
            case "v":
                verbose = true
            case "h":
                help = true
            case "t":
                methTypeObfuscation = true
            case "D":
                machOViewDoom = true
            case "m":
                manglerKey = String(cString: optarg)
            default:
                fatalError("Unexpected argument: \(char)")
            }
        }

        var appDirectory: String?
        if optind < argc {
            appDirectory = argv[Int(optind)]
        }

        let manglerType = SymbolManglers(rawValue: manglerKey)

        let appDirectoryURL = appDirectory
            .flatMap(URL.init(fileURLWithPath:))?
            .resolvingSymlinksInPath()

        self.init(help: help,
                  quiet: quiet,
                  verbose: verbose,
                  methTypeObfuscation: methTypeObfuscation,
                  machOViewDoom: machOViewDoom,
                  manglerType: manglerType,
                  appDirectory: appDirectoryURL)
    }

    static var usage: String {
        return """
        usage: \(CommandLine.arguments[0]) [-qvhD] [-m mangler_key] APP_BUNDLE

          Obfuscates application APP_BUNDLE in-place.

        Options:
          -h              help screen (this screen)
          -q              quiet mode, no output to stdout
          -v              verbose mode, output verbose info to stdout
          -D              MachOViewDoom, MachOView crashes after trying to open your binary (doesn't work with caesarMangler)
          -m mangler_key  select mangler to generate obfuscated symbols

        \(SymbolManglers.helpSummary)
        """
    }
}
