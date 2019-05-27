import XCTest

class Mach_Replacing_importEntries_Tests: XCTestCase {

    var sut: Image!
    var firstImportEntry: ImportStackEntry!
    var originalSymbolBytes: [UInt8]!
    var randomSubstitutionBytes: [UInt8]!
    var symbolDylib: String!

    override func setUp() {
        super.setUp()

        sut = try! Image.load(url: URL.machoMacExecutable)
        firstImportEntry = sut.machs[0].importStack![0]
        originalSymbolBytes = firstImportEntry.symbol
        randomSubstitutionBytes = originalSymbolBytes.randomSymbolSubstitution
        symbolDylib = sut.machs[0].dylibs[firstImportEntry.dylibOrdinal - 1]
    }

    override func tearDown() {
        sut = nil
        firstImportEntry = nil
        originalSymbolBytes = nil
        randomSubstitutionBytes = nil
        symbolDylib = nil

        super.tearDown()
    }

    func test_shouldReplaceImportEntrySymbolWithObfuscationMap() {
        // Given
        let map = SymbolManglingMap(selectors: [:], classNames: [:], exportTrieObfuscationMap: [
            URL.machoMacExecutable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.empty,
                     obfuscated: Trie.empty)],
            URL.sampleDylib: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.with(labelBytes: originalSymbolBytes),
                     obfuscated: Trie.with(labelBytes: randomSubstitutionBytes))],
        ])
        let paths = ObfuscationPaths(resolvedDylibMapPerImageURL:
            [URL.machoMacExecutable:[symbolDylib: URL.sampleDylib]])

        // When
        sut.replaceSymbols(withMap: map, paths: paths)

        // Then
        let dataAtSymbolRange = sut.machs[0].data[firstImportEntry.symbolRange]
        XCTAssertEqual(dataAtSymbolRange, Data(randomSubstitutionBytes))
    }

    func test_shouldNotReplaceImportEntrySymbol_whenObfuscationMapMissesSymbol() {
        // Given
        let map = SymbolManglingMap(selectors: [:], classNames: [:], exportTrieObfuscationMap: [
            URL.machoMacExecutable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.empty,
                     obfuscated: Trie.empty)],
            URL.sampleDylib: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.empty,
                     obfuscated: Trie.empty)],
            ])
        let paths = ObfuscationPaths(resolvedDylibMapPerImageURL:
            [URL.machoMacExecutable:[symbolDylib: URL.sampleDylib]])

        // When
        sut.replaceSymbols(withMap: map, paths: paths)

        // Then
        let dataAtSymbolRange = sut.machs[0].data[firstImportEntry.symbolRange]
        XCTAssertEqual(dataAtSymbolRange, Data(originalSymbolBytes))
    }

    func test_shouldNotReplaceImportEntrySymbol_whenObfuscationMapMissesDylib() {
        // Given
        let map = SymbolManglingMap(selectors: [:], classNames: [:], exportTrieObfuscationMap: [
            URL.machoMacExecutable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.empty,
                     obfuscated: Trie.empty)]]
        )
        let paths = ObfuscationPaths(resolvedDylibMapPerImageURL:
            [URL.machoMacExecutable:[symbolDylib: URL.sampleDylib]])

        // When
        sut.replaceSymbols(withMap: map, paths: paths)

        // Then
        let dataAtSymbolRange = sut.machs[0].data[firstImportEntry.symbolRange]
        XCTAssertEqual(dataAtSymbolRange, Data(originalSymbolBytes))
    }

    func test_shouldNotReplaceImportEntrySymbol_whenObfuscationPathDoesntContainResolverDylib() {
        // Given
        let map = SymbolManglingMap(selectors: [:], classNames: [:], exportTrieObfuscationMap: [
            URL.machoMacExecutable: [
                sut.machs[0].cpu.asCpuId:
                    (unobfuscated: Trie.empty,
                     obfuscated: Trie.empty)]]
        )
        let paths = ObfuscationPaths(resolvedDylibMapPerImageURL: [URL.machoMacExecutable: [:]])

        // When
        sut.replaceSymbols(withMap: map, paths: paths)

        // Then
        let dataAtSymbolRange = sut.machs[0].data[firstImportEntry.symbolRange]
        XCTAssertEqual(dataAtSymbolRange, Data(originalSymbolBytes))
    }
}

private extension Array where Element == UInt8 {
    var randomSymbolSubstitution: [UInt8] {
        return map { _ in UInt8.random(in: 0x20...0x7E) }
    }
}

private extension Trie {
    static let empty = Trie(exportsSymbol: false, labelRange: 0..<0, label: [], children: [])
    static func with(labelBytes: [UInt8]) -> Trie {
        return Trie(exportsSymbol: false,
                    labelRange: 0..<0,
                    label: labelBytes,
                    children: [ Trie(exportsSymbol: true, labelRange: 0..<0, label: [], children: []) ])

    }
}

private extension URL {
    static let sampleDylib = URL(fileURLWithPath: "/tmp/lib7")
}

private extension ObfuscationPaths {
    init(resolvedDylibMapPerImageURL: [URL: [String: URL]]) {
        self.init(obfuscableImages: [URL.machoMacExecutable, URL.sampleDylib],
                  unobfuscableDependencies: [],
                  systemFrameworks: [],
                  resolvedDylibMapPerImageURL: resolvedDylibMapPerImageURL,
                  nibs: [])
    }
}
