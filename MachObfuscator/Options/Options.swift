import Foundation

struct EraseSectionConfiguration {
    var sectionName: String
    var segmentName: String
}

private extension EraseSectionConfiguration {
    init(sectionDef: String) {
        let sectionParts = sectionDef.split(separator: ",")
        guard sectionParts.count == 2 else {
            fatalError("Section must by pointed with SEGMENT,SECTION format")
        }
        self.init(sectionName: String(sectionParts[1]), segmentName: String(sectionParts[0]))
    }
}

struct Options {
    var help = false
    var dryrun = false
    var quiet = false
    var verbose = false
    var debug = false
    var machOViewDoom = false
    var methTypeObfuscation = false
    var swiftReflectionObfuscation = false
    var eraseSections: [EraseSectionConfiguration] = []
    var obfuscableFilesFilter = ObfuscableFilesFilter.defaultObfuscableFilesFilter()
    var manglerType: SymbolManglers? = SymbolManglers.defaultMangler
    var skippedSymbolsSources: [URL] = []
    var appDirectory: URL?
}

extension Options {
    typealias UnsafeArgv = UnsafeMutablePointer<UnsafeMutablePointer<Int8>?>

    static func fromCommandLine() -> Options {
        return self.init(argc: CommandLine.argc,
                         unsafeArgv: CommandLine.unsafeArgv,
                         argv: CommandLine.arguments)
    }

    static func newCCharPtrFromStaticString(_ str: StaticString) -> UnsafePointer<CChar> {
        let rp = UnsafeRawPointer(str.utf8Start)
        let rplen = str.utf8CodeUnitCount
        return rp.bindMemory(to: CChar.self, capacity: rplen)
    }

    init(argc: Int32, unsafeArgv: UnsafeArgv, argv: [String]) {
        optreset = 1

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
            case OPT_FIRST = 256
            case swiftReflection
            case eraseSection
            case skipFramework
            case skipAllFrameworks
            case skipSymbolsFromSources
            case dryrun
        }

        let longopts: [option] = [
            option(name: Options.newCCharPtrFromStaticString("help"), has_arg: no_argument, flag: nil, val: OptLongChars.help),
            option(name: Options.newCCharPtrFromStaticString("verbose"), has_arg: no_argument, flag: nil, val: OptLongChars.verbose),
            option(name: Options.newCCharPtrFromStaticString("dry-run"), has_arg: no_argument, flag: nil, val: OptLongCases.dryrun.rawValue),
            option(name: Options.newCCharPtrFromStaticString("methtype"), has_arg: no_argument, flag: nil, val: OptLongChars.methTypeObfuscation),
            option(name: Options.newCCharPtrFromStaticString("machoview-doom"), has_arg: no_argument, flag: nil, val: OptLongChars.machOViewDoom),
            option(name: Options.newCCharPtrFromStaticString("swift-reflection"), has_arg: no_argument, flag: nil, val: OptLongCases.swiftReflection.rawValue),
            option(name: Options.newCCharPtrFromStaticString("erase-section"), has_arg: required_argument, flag: nil, val: OptLongCases.eraseSection.rawValue),
            option(name: Options.newCCharPtrFromStaticString("skip-framework"), has_arg: required_argument, flag: nil, val: OptLongCases.skipFramework.rawValue),
            option(name: Options.newCCharPtrFromStaticString("skip-all-frameworks"), has_arg: no_argument, flag: nil, val: OptLongCases.skipAllFrameworks.rawValue),
            option(name: Options.newCCharPtrFromStaticString("mangler"), has_arg: required_argument, flag: nil, val: OptLongChars.manglerKey),
            option(name: Options.newCCharPtrFromStaticString("skip-symbols-from-sources"), has_arg: required_argument, flag: nil, val: OptLongCases.skipSymbolsFromSources.rawValue),
            option(), // { NULL, NULL, NULL, NULL }
        ]

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
            case OptLongCases.dryrun.rawValue:
                dryrun = true
            case OptLongChars.methTypeObfuscation:
                methTypeObfuscation = true
            case OptLongChars.machOViewDoom:
                machOViewDoom = true
            case OptLongChars.manglerKey:
                manglerType = SymbolManglers(rawValue: String(cString: optarg))
            case OptLongCases.swiftReflection.rawValue:
                swiftReflectionObfuscation = true
            case OptLongCases.eraseSection.rawValue:
                eraseSections.append(EraseSectionConfiguration(sectionDef: String(cString: optarg)))
            case OptLongCases.skipFramework.rawValue:
                obfuscableFilesFilter = obfuscableFilesFilter.and(ObfuscableFilesFilter.skipFramework(framework: String(cString: optarg)))
            case OptLongCases.skipAllFrameworks.rawValue:
                obfuscableFilesFilter = obfuscableFilesFilter.and(ObfuscableFilesFilter.skipAllFrameworks())
            case OptLongCases.skipSymbolsFromSources.rawValue:
                let sourcesPath = URL(fileURLWithPath: String(cString: optarg))
                skippedSymbolsSources.append(sourcesPath)
            case OptLongChars.unknownOption:
                help = true
            default:
                fatalError("Unexpected argument: \(option)")
            }
        }

        var appDirectory: String?
        if optind < argc {
            appDirectory = argv[Int(optind)]
        }

        self.appDirectory = appDirectory
            .flatMap(URL.init(fileURLWithPath:))?
            .resolvingSymlinksInPath()
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
          --dry-run               analyze only, do not save obfuscated images
        
          -t, --methtype          obfuscate methType section (objc/runtime.h methods may work incorrectly)
          -D, --machoview-doom    MachOViewDoom, MachOView crashes after trying to open your binary (doesn't work with caesarMangler)
          --swift-reflection      obfuscate Swift reflection sections (typeref and reflstr). May cause problems for Swift >= 4.2
          --erase-section SEGMENT,SECTION    erase given section, for example: __TEXT,__swift5_reflstr
        
          --skip-all-frameworks       do not obfuscate frameworks
          --skip-framework framework  do not obfuscate given framework
        
          -m mangler_key,
          --mangler mangler_key   select mangler to generate obfuscated symbols

          --skip-symbols-from-sources PATH
                                  Don't obfuscate all the symbols found in PATH (searches for all nested *.[hm] files).
                                  This option can be used multiple times to add multiple paths.

        \(SymbolManglers.helpSummary)
        """
    }
}
