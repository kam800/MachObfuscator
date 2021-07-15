import Foundation

extension NibArchive {
    private enum SupportedConsts {
        static let header: [UInt8] = Array("NIBArchive".utf8)
        static let const1: UInt32 = 1
        static let const2: UInt32 = 9
    }

    static func canLoad(from url: URL) -> Bool {
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Could not read \(url)")
        }
        let headerData: [UInt8] = data.getStructs(atOffset: 0, count: 10)
        let const1: UInt32 = data.getStruct(atOffset: 10)
        let const2: UInt32 = data.getStruct(atOffset: 14)
        return headerData == SupportedConsts.header
            && const1 == SupportedConsts.const1
            && const2 == SupportedConsts.const2
    }

    static func load(from url: URL) -> Nib {
        let data = try! Data(contentsOf: url)
        let headerData: [UInt8] = data.getStructs(atOffset: 0, count: 10)
        precondition(headerData == SupportedConsts.header, "Unsupported NIBArchive header")
        let const1: UInt32 = data.getStruct(atOffset: 10)
        precondition(const1 == SupportedConsts.const1, "Unsupported NIBArchive version")
        let const2: UInt32 = data.getStruct(atOffset: 14)
        precondition(const2 == SupportedConsts.const2, "Unsupported NIBArchive version")
        let objectsCount = Int(data.getStruct(atOffset: 18) as UInt32)
        let objectsOffset = Int(data.getStruct(atOffset: 22) as UInt32)
        let keyCount = Int(data.getStruct(atOffset: 26) as UInt32)
        let keyOffset = Int(data.getStruct(atOffset: 30) as UInt32)
        let valueCount = Int(data.getStruct(atOffset: 34) as UInt32)
        let valueOffset = Int(data.getStruct(atOffset: 38) as UInt32)
        let classCount = Int(data.getStruct(atOffset: 42) as UInt32)
        let classOffset = Int(data.getStruct(atOffset: 46) as UInt32)
        let objects = data.parse(block: { ptr, _ in ptr.parseNextObject() },
                                 offset: objectsOffset,
                                 count: objectsCount)
        let values = data.parse(block: { ptr, zeroPtr in ptr.parseNextValue(zeroPtr: zeroPtr) },
                                offset: valueOffset,
                                count: valueCount)
        let keys = data.parse(block: { ptr, zeroPtr in ptr.parseNextKey(zeroPtr: zeroPtr) },
                              offset: keyOffset,
                              count: keyCount)
        let classes = data.parse(block: { ptr, zeroPtr in ptr.parseNextClass(zeroPtr: zeroPtr) },
                                 offset: classOffset,
                                 count: classCount)

        return NibArchive(url: url,
                          data: data,
                          objects: objects,
                          values: values,
                          keys: keys,
                          classes: classes)
    }
}

private extension Data {
    func parse<T>(block: (inout UnsafeRawPointer, UnsafeRawPointer) -> T,
                  offset: Int,
                  count: Int) -> [T] {
        return withUnsafeBytes { (bytes: UnsafeRawBufferPointer) in
            var cursor = bytes.baseAddress!.advanced(by: offset)
            var elementsLeft = count
            var elements: [T] = []
            while elementsLeft > 0 {
                elements.append(block(&cursor, bytes.baseAddress!))
                elementsLeft -= 1
            }
            return elements
        }
    }
}

private extension UnsafeRawPointer {
    mutating func parseNextObject() -> NibArchive.Object {
        return NibArchive.Object(classIndex: Int(readNibUleb128()),
                                 valuesIndex: Int(readNibUleb128()),
                                 valuesCount: Int(readNibUleb128()))
    }

    mutating func parseNextKey(zeroPtr: UnsafeRawPointer) -> NibArchive.RangedString {
        let keyBytesCount = Int(readNibUleb128())
        let keyOffset = zeroPtr.distance(to: self)
        let keyBytes: [UInt8] = getStructs(count: keyBytesCount)
        guard let key = String(bytes: keyBytes, encoding: .utf8) else {
            fatalError("NIBArchive key is not an UTF8 string")
        }
        self = advanced(by: keyBytesCount)
        let keyLimit = zeroPtr.distance(to: self)
        return NibArchive.RangedString(value: key,
                                       range: keyOffset ..< keyLimit)
    }

    mutating func parseNextValue(zeroPtr: UnsafeRawPointer) -> NibArchive.Value {
        let keyIndex = Int(readNibUleb128())
        let value: NibArchive.Value.ValueType
        let valueType: UInt8 = readStruct()
        var valueOffset = zeroPtr.distance(to: self)
        switch valueType {
        case 0:
            value = .int8(readStruct())
        case 1:
            value = .int16(readStruct())
        case 2:
            value = .int32(readStruct())
        case 3:
            value = .int64(readStruct())
        case 4:
            value = .boolTrue
        case 5:
            value = .boolFalse
        case 6:
            value = .float(readStruct())
        case 7:
            value = .double(readStruct())
        case 8:
            let bytesCount = Int(readNibUleb128())
            valueOffset = zeroPtr.distance(to: self)
            let bytes: [UInt8] = readStructs(count: bytesCount)
            value = .data(Data(bytes))
        case 9:
            value = .null
        case 10:
            let objectIndex = Int(readStruct() as Int32)
            value = .object(objectIndex)
        default:
            fatalError("Unsupported value type: \(valueType)")
        }
        let valueLimit = zeroPtr.distance(to: self)
        return NibArchive.Value(keyIndex: keyIndex,
                                value: value,
                                valueRange: valueOffset ..< valueLimit)
    }

    mutating func parseNextClass(zeroPtr: UnsafeRawPointer) -> NibArchive.RangedString {
        let nameBytesCount = readNibUleb128()
        let extraValues = readNibUleb128()
        let extraValuesBytesSize = 4 * Int(extraValues)
        self = advanced(by: extraValuesBytesSize)
        var nameBytes: [UInt8] = getStructs(count: Int(nameBytesCount))
        // TODO: remove?
        while nameBytes.last == 0 {
            nameBytes.removeLast()
        }
        let name = String(bytes: nameBytes, encoding: .utf8)!
        let nameOffset = zeroPtr.distance(to: self)
        self = advanced(by: Int(nameBytesCount))
        let nameLimit = zeroPtr.distance(to: self)
        return NibArchive.RangedString(value: name,
                                       range: nameOffset ..< nameLimit)
    }
}
