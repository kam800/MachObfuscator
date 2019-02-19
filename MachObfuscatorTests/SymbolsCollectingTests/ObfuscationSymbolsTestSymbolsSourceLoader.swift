import Foundation

struct SymbolsSourceMock: SymbolsSource {
    var selectors: [String]
    var classNames: [String]
    var cstrings: [String]
    var exportedTrie: Trie?
    var cpu: Mach.Cpu
}

extension SymbolsSourceMock {
    static func with(selectors: [String] = [],
                     classNames: [String] = [],
                     cstrings: [String] = [],
                     exportedTrie: Trie? = nil,
                     cpuType: Int32 = 0x17, cpuSubtype: Int32 = 0x42) -> SymbolsSourceMock {
        return SymbolsSourceMock(selectors: selectors,
                                 classNames: classNames,
                                 cstrings: cstrings,
                                 exportedTrie: exportedTrie,
                                 cpu: Mach.Cpu(type: cpuType, subtype: cpuSubtype))
    }
}

extension Trie {
    static func with(label: String) -> Trie {
        let labelBytes: [UInt8] = [UInt8](label.utf8)
        return Trie(exportsSymbol: false,
                    labelRange: (UInt64(0)..<UInt64(0)),
                    label: labelBytes,
                    children: [])
    }
    var labelString: String? {
        return String(bytes: label, encoding: .utf8)
    }
}

class ObfuscationSymbolsTestSymbolsSourceLoader {

    fileprivate enum Error: Swift.Error {
        case noEntryForPath
    }

    private var sourcesPerUrl: [String: [SymbolsSource]] = [:]

    subscript(path: String) -> [SymbolsSource] {
        get {
            return sourcesPerUrl[path] ?? []
        }
        set {
            sourcesPerUrl[path] = newValue
        }
    }
}

extension ObfuscationSymbolsTestSymbolsSourceLoader: SymbolsSourceLoader {
    func load(forURL url: URL) throws -> [SymbolsSource] {
        let path = url.resolvingSymlinksInPath().path
        if let sources = sourcesPerUrl[path] {
            return sources
        } else {
            throw Error.noEntryForPath
        }
    }
}
