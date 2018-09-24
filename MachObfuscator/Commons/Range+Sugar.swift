extension Range where Bound: BinaryInteger {
    init(offset: Bound, count: Bound) {
        self = offset ..< (offset + count)
    }

    var intRange: Range<Int> {
        return Int(lowerBound) ..< Int(upperBound)
    }
}
