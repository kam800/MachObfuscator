import Foundation

class SoutLogger {
    enum Verbosity: Int {
        case quiet
        case warning
        case info
    }

    fileprivate let verbosity: Verbosity

    init(verbosity: Verbosity) {
        self.verbosity = verbosity
    }
}

extension SoutLogger: Logger {
    func info(_ text: @autoclosure () -> String) {
        log(text: text, level: .info)
    }

    func warn(_ text: @autoclosure () -> String) {
        log(text: "WARN: \(text())", level: .warning)
    }

    private func log(text: @autoclosure () -> String, level: Verbosity) {
        guard level.rawValue <= verbosity.rawValue else {
            return
        }
        print(text())
    }
}
