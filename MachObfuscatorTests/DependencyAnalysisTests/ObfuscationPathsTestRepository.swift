import Foundation
import XCTest

class ObfuscationPathsTestRepository {
    private enum Entry {
        case MachO(platform: Mach.Platform, isExecutable: Bool, dylibs: [String], rpaths: [String], cstrings: [String])
        case File
    }

    private enum Error: Swift.Error {
        case noEntryForPath
    }

    private var entryPerPath: [String: Entry] = [:]
    var expectedRoot: URL?

    func addFilePath(_ path: String) {
        entryPerPath[path] = .File
    }

    func addMachOPath(_ path: String,
                      platform: Mach.Platform = .macos,
                      isExecutable: Bool,
                      dylibs: [String] = [],
                      rpaths: [String] = [],
                      cstrings: [String] = []) {
        entryPerPath[path] = .MachO(platform: platform,
                                    isExecutable: isExecutable,
                                    dylibs: dylibs,
                                    rpaths: rpaths,
                                    cstrings: cstrings)
    }
}

extension ObfuscationPathsTestRepository: FileRepository {
    func listFilesRecursively(atURL url: URL) -> [URL] {
        XCTAssertEqual(url, expectedRoot)
        return entryPerPath.keys.map(URL.init(fileURLWithPath:))
    }

    func fileExists(atURL url: URL) -> Bool {
        return entryPerPath.keys.contains(
            url.resolvingSymlinksInPath().path
        )
    }
}

extension ObfuscationPathsTestRepository: DependencyNodeLoader {
    func load(forURL url: URL) throws -> [DependencyNode] {
        switch entryPerPath[url.resolvingSymlinksInPath().path] {
        case let .MachO(platform: platform,
                        isExecutable: isExecutable,
                        dylibs: dylibs,
                        rpaths: rpaths,
                        cstrings: cstrings)?:
            let mach = DependencyNodeMock(isExecutable: isExecutable,
                                          platform: platform,
                                          rpaths: rpaths,
                                          dylibs: dylibs,
                                          cstrings: cstrings)
            return [mach]
        default:
            throw Error.noEntryForPath
        }
    }
}

private struct DependencyNodeMock: DependencyNode {
    var isExecutable: Bool
    var platform: Mach.Platform
    var rpaths: [String]
    var dylibs: [String]
    var cstrings: [String]
}
