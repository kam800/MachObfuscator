protocol DependencyNode {
    var isExecutable: Bool { get }
    var platform: Mach.Platform { get }
    var rpaths: [String] { get }
    var dylibs: [String] { get }
}
