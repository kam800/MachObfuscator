protocol Logger {
    func info(_: @autoclosure () -> String)
    func warn(_: @autoclosure () -> String)
}

var LOGGER: Logger!
