import Foundation

struct Options {
    var help: Bool
    var quiet: Bool
    var verbose: Bool
    var debug: Bool
    var methTypeObfuscation: Bool
    var machOViewDoom: Bool
    var swiftReflectionObfuscation = false
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
    static func newCCharPtrFromStaticString(_ str: StaticString) -> UnsafePointer<CChar>
    {
        let rp = UnsafeRawPointer(str.utf8Start);
        let rplen = str.utf8CodeUnitCount;
        return rp.bindMemory(to: CChar.self, capacity: rplen);
    }
    
    init(argc: Int32, unsafeArgv: UnsafeArgv, argv: [String]) {
        optreset = 1
        var help = false
        var quiet = false
        var verbose = false
        var debug = false
        var machOViewDoom = false
        var methTypeObfuscation = false
        var swiftReflectionObfuscation = false
        var manglerKey = SymbolManglers.defaultManglerKey
        
        struct OptLongChars {
            static let unknownOption = Int32(Character("?").asciiValue!)
            static let help = Int32(Character("h").asciiValue!)
            static let verbose = Int32(Character("v").asciiValue!)
            static let quiet = Int32(Character("q").asciiValue!)
            static let debug = Int32(Character("d").asciiValue!)
            static let methTypeObfuscation = Int32(Character("t").asciiValue!)
            static let machOViewDoom = Int32(Character("D").asciiValue!)
            static let manglerKey = Int32(Character("m").asciiValue!)
        }
        enum OptLongCases: Int32 {
            case OPT_FIRST = 256;
            case swiftReflection;
        };
        
        let longopts: [option] = [
            option(name: Options.newCCharPtrFromStaticString("help"),      has_arg: no_argument,       flag: nil, val: OptLongChars.help),
            option(name: Options.newCCharPtrFromStaticString("verbose"),   has_arg: no_argument,       flag: nil, val: OptLongChars.verbose),
            option(name: Options.newCCharPtrFromStaticString("methtype"),      has_arg: no_argument, flag: nil, val: OptLongChars.methTypeObfuscation),
            option(name: Options.newCCharPtrFromStaticString("machoview-doom"),      has_arg: no_argument, flag: nil, val: OptLongChars.machOViewDoom),
            option(name: Options.newCCharPtrFromStaticString("swift-reflection"),      has_arg: no_argument, flag: nil, val: OptLongCases.swiftReflection.rawValue),
            option(name: Options.newCCharPtrFromStaticString("mangler"),      has_arg: required_argument, flag: nil, val: OptLongChars.manglerKey),
            option()    // { NULL, NULL, NULL, NULL }
        ];
        
        while case let option = getopt_long(argc, unsafeArgv, "qvdhtDm:", longopts, nil), option != -1 {
            switch option {
            case OptLongChars.quiet:
                quiet = true
            case OptLongChars.verbose:
                verbose = true
            case OptLongChars.debug:
                debug = true
            case OptLongChars.help:
                help = true
            case OptLongChars.methTypeObfuscation:
                methTypeObfuscation = true
            case OptLongChars.machOViewDoom:
                machOViewDoom = true
            case OptLongChars.manglerKey:
                manglerKey = String(cString: optarg)
            case OptLongCases.swiftReflection.rawValue:
                swiftReflectionObfuscation = true;
            case OptLongChars.unknownOption:
                help = true
                break
            default:
                fatalError("Unexpected argument: \(option)")
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
                  debug: debug,
                  methTypeObfuscation: methTypeObfuscation,
                  machOViewDoom: machOViewDoom,
                  swiftReflectionObfuscation: swiftReflectionObfuscation,
                  manglerType: manglerType,
                  appDirectory: appDirectoryURL)
    }

    static var usage: String {
        return """
        usage: \(CommandLine.arguments[0]) [-qvdhtD] [-m mangler_key] APP_BUNDLE

          Obfuscates application APP_BUNDLE in-place.

        Options:
          -h, --help              help screen (this screen)
          -q, --quiet             quiet mode, no output to stdout
          -v, --verbose           verbose mode, output verbose info to stdout
          -d, --debug             debug mode, output more verbose info to stdout
        
          -t, --methtype          obfuscate methType section (objc/runtime.h methods may work incorrectly)
          -D, --machoview-doom    MachOViewDoom, MachOView crashes after trying to open your binary (doesn't work with caesarMangler)
          --swift-reflection      obfuscate Swift reflection sections (typeref and reflstr). May cause problems for Swift >= 4.2
          -m mangler_key,
          --mangler mangler_key   select mangler to generate obfuscated symbols

        \(SymbolManglers.helpSummary)
        """
    }
}
