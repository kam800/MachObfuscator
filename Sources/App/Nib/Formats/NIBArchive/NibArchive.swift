import Foundation

struct NibArchive {
    var url: URL
    var data: Data

    // Those properties do not update when modyfing data. They are kind of cache.
    // TODO: what to do with them?
    let objects: [Object]
    let values: [Value]
    let keys: [RangedString]
    let classes: [RangedString]

    struct Object {
        var classIndex: Int
        var valuesIndex: Int
        var valuesCount: Int
    }

    struct Value {
        enum ValueType {
            case int8(Int8)
            case int16(Int16)
            case int32(Int32)
            case int64(Int64)
            case boolTrue
            case boolFalse
            case float(Float)
            case double(Double)
            case data(Data)
            case null
            case object(Int)
        }

        var keyIndex: Int
        var value: ValueType
        var valueRange: Range<Int>
    }

    struct RangedString {
        var value: String
        var range: Range<Int>
    }
}
