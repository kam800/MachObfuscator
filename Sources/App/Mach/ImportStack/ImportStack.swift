import Foundation

typealias ImportStack = [ImportStackEntry]

struct ImportStackEntry {
    var dylibOrdinal: Int
    var symbol: [UInt8]
    var symbolRange: Range<UInt64>
    var weak: Bool // should be skipped when dylib is missing
}
