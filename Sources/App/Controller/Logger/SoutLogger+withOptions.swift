import Foundation

extension SoutLogger {
    convenience init(options: Options) {
        let verbosity: SoutLogger.Verbosity

        if options.quiet {
            verbosity = .quiet
        } else if options.debug {
            verbosity = .debug
        } else if options.verbose {
            verbosity = .info
        } else {
            verbosity = .warning
        }

        self.init(verbosity: verbosity)
    }
}
