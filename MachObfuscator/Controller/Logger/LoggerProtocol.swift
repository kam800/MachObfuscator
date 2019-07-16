protocol Logger {
    func debug(_: @autoclosure () -> String)
    func info(_: @autoclosure () -> String)
    func warn(_: @autoclosure () -> String)
}

var LOGGER: Logger = VoidLogger()

private class VoidLogger: Logger {
    func debug(_: () -> String) {}
    func info(_: () -> String) {}
    func warn(_: () -> String) {}
}
