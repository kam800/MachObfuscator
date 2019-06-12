protocol Logger {
    func debug(_: @autoclosure () -> String)
    func info(_: @autoclosure () -> String)
    func warn(_: @autoclosure () -> String)
}

var LOGGER: Logger!
