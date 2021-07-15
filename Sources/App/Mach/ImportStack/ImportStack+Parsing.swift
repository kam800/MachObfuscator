extension ImportStackEntry {
    var symbolString: String {
        return String(bytes: symbol, encoding: .utf8)!
    }
}
