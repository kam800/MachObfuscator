import Foundation

// TODO: this is only for debug, remove

extension NibArchive {
    func humanReadable() {
        var visitedObjects: Set<Int> = []
        objects.enumerated().forEach { idx, object in
            if !visitedObjects.contains(idx) {
                print("=== object #\(idx) ===")
                print(object.humanReadable(forNib: self,
                                           visitedObjects: &visitedObjects,
                                           objectsStack: [idx]))
            }
        }
    }
}

private extension NibArchive.Object {
    func humanReadable(forNib nib: NibArchive, visitedObjects: inout Set<Int>, objectsStack: [Int]) -> String {
        let className = nib.classes[Int(classIndex)]
        var lines: [String] = ["object \(className.value) {"]

        let range = Range(offset: UInt64(valuesIndex), count: UInt64(valuesCount)).intRange
        let objectValues = nib.values[range]
        objectValues.forEach { value in
            let key = nib.keys[Int(value.keyIndex)].value
            let valueStr = value.value
                .humanReadable(forNib: nib, visitedObjects: &visitedObjects, objectsStack: objectsStack)
                .split(separator: "\n")
                .enumerated()
                .map { offset, element in offset == 0 ? element : "    " + element }
                .joined(separator: "\n")
            lines.append("  \(key) -> \(valueStr)")
        }

        lines.append("}")
        return lines.joined(separator: "\n")
    }
}

extension NibArchive.Value.ValueType {
    func humanReadable(forNib nib: NibArchive, visitedObjects: inout Set<Int>, objectsStack: [Int]) -> String {
        switch self {
        case let .int8(i):
            return "\(i)"
        case let .int16(i):
            return "\(i)"
        case let .int32(i):
            return "\(i)"
        case let .int64(i):
            return "\(i)"
        case .boolTrue:
            return "true"
        case .boolFalse:
            return "false"
        case let .float(f):
            return "\(f)"
        case let .double(d):
            return "\(d)"
        case let .data(d):
            return String(bytes: d, encoding: .utf8) ?? d.description
        case .null:
            return "(null)"
        case let .object(o):
            let object = nib.objects[o]
            if objectsStack.contains(o) {
                let className = nib.classes[Int(object.classIndex)]
                return "object #\(o) \(className.value) (cycle)"
            } else {
                visitedObjects.insert(Int(o))
                return object.humanReadable(forNib: nib, visitedObjects: &visitedObjects, objectsStack: objectsStack + [o])
            }
        }
    }
}
