import Foundation

extension NibArchive: Nib {
    var selectors: [String] {
        return runtimeSelectorConnectionLabels.map { $0.value }
    }

    var classNames: [String] {
        return uiClassNames.map { $0.value }
    }

    mutating func modifySelectors(withMapping map: [String: String]) {
        modify(rangedStrings: runtimeSelectorConnectionLabels, map: map)
    }

    mutating func modifyClassNames(withMapping map: [String: String]) {
        modify(rangedStrings: uiClassNames, map: map)
    }

    private mutating func modify(rangedStrings: [RangedString], map: [String: String]) {
        rangedStrings.compactMap { label in
            map[label.value].flatMap { mappedLabel in (mappedLabel, label.range) }
        }.forEach { mappedLabel, range in
            let mappedLabelBytes = [UInt8](mappedLabel.utf8)
            guard mappedLabelBytes.count <= range.count else {
                fatalError("Mapped label \(mappedLabel) does not fit into range of \(range.count) bytes")
            }
            let padding = [UInt8](repeating: 0, count: (range.count - mappedLabelBytes.count))
            let paddedMappedLabel = mappedLabelBytes + padding
            data.replaceBytes(inRange: range, withBytes: paddedMappedLabel)
        }
    }
}

private extension NibArchive {
    var runtimeSelectorConnectionObjects: [Object] {
        return objects.filter { object in
            let classValue = object.getClass(formNib: self).value
            return classValue == "UIRuntimeOutletConnection"
                || classValue == "UIRuntimeEventConnection"
        }
    }

    var runtimeSelectorConnectionLabels: [RangedString] {
        return runtimeSelectorConnectionObjects.map { $0.uiLabel(fromNib: self) }
    }

    var uiClassNames: [RangedString] {
        guard let classNameKeyIndex = keys.index(where: { $0.value == "UIClassName" })
        else { return [] }
        let classNameValues = values.filter { value in
            return value.keyIndex == classNameKeyIndex
        }
        return classNameValues.map { value in
            guard let rangedString = value.asString(nib: self)
            else { fatalError("`UIClassName` is not a string") }
            return rangedString
        }
    }
}

private extension NibArchive.Value {
    func asString(nib: NibArchive) -> NibArchive.RangedString? {
        guard case let .object(uiLabelObjectIdx) = value else { return nil }
        let uiLabelObject = nib.objects[uiLabelObjectIdx]
        guard let nsBytes = uiLabelObject.value(byKey: "NS.bytes", fromNib: nib) else { return nil }
        guard case let .data(labelData) = nsBytes.value else { return nil }
        let labelBytes: [UInt8] = labelData.getStructs(atOffset: 0, count: labelData.count).withoutTrailingZeros
        guard let labelString = String(bytes: labelBytes, encoding: .utf8) else { return nil }
        return NibArchive.RangedString(value: labelString,
                                       range: Range(offset: nsBytes.valueRange.lowerBound,
                                                    count: labelBytes.count))
    }
}

private extension NibArchive.Object {
    func uiLabel(fromNib nib: NibArchive) -> NibArchive.RangedString {
        guard let value = value(byKey: "UILabel", fromNib: nib) else {
            fatalError("object has no UILabel")
        }
        guard let rangedString = value.asString(nib: nib) else {
            fatalError("object.Label is not a String")
        }
        return rangedString
    }

    func getClass(formNib nib: NibArchive) -> NibArchive.RangedString {
        return nib.classes[classIndex]
    }

    func value(byKey key: String, fromNib nib: NibArchive) -> NibArchive.Value? {
        // TODO: O(n) -> O(log(n))
        return values(fromNib: nib).first { value in
            let valueKey = nib.keys[value.keyIndex]
            return valueKey.value == key
        }
    }

    private func values(fromNib nib: NibArchive) -> ArraySlice<NibArchive.Value> {
        return nib.values[valuesRange]
    }

    private var valuesRange: Range<Int> {
        return Range(offset: valuesIndex, count: valuesCount).intRange
    }
}

private extension Array where Element == UInt8 {
    var withoutTrailingZeros: [UInt8] {
        var result = self
        // TODO: remove?
        while result.last == 0 {
            result.removeLast()
        }
        return result
    }
}
