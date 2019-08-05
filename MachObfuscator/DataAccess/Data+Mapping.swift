import Foundation

extension Data {
    private func stringRangesPerString(inRange range: Range<Int>) -> [String: [Range<Int>]] {
        let enumeratedBytes = Array(enumerated())[range]
        let chunksOfEnumeratedBytes = enumeratedBytes.split { _, data in data == 0 }
        let stringWithRangePairs: [(String, Range<Int>)] = chunksOfEnumeratedBytes.compactMap { chunk in
            let chunkBytes = chunk.map { _, data in data }
            guard let string = String(bytes: chunkBytes, encoding: .utf8) else {
                return nil
            }
            let chunkArray = Array(chunk)
            let range = (chunkArray.first!.offset ..< (chunkArray.last!.offset + 1))
            return (string, range)
        }
        return Dictionary(grouping: stringWithRangePairs) { string, _ in string }
            .mapValues { $0.map { _, range in range } }
    }

    mutating func replaceStrings(inRange range: Range<Int>, withMapping mapping: [String: String]) {
        let rangesPerString = stringRangesPerString(inRange: range)
        mapping.forEach { originalString, mappedString in
            precondition(originalString.utf8.count == mappedString.utf8.count)
            if let stringRanges = rangesPerString[originalString] {
                stringRanges.forEach { stringRange in
                    let targetData = mappedString.data(using: .utf8)!
                    precondition(targetData.count == stringRange.count)
                    replaceSubrange(stringRange, with: targetData)
                }
            }
        }
    }

    mutating func replaceStrings(inRange range: Range<Int>, withMapping mapping: (String) -> String, withFilter filter: (String) -> Bool = { _ in true }) {
        let rangesPerString = stringRangesPerString(inRange: range)
        rangesPerString.filter { filter($0.key) }.forEach { originalString, ranges in
            let mappedString = mapping(originalString)
            precondition(originalString.utf8.count >= mappedString.utf8.count)
            ranges.forEach {
                replaceRangeWithPadding($0, with: mappedString)
            }
        }
    }

    mutating func replaceBytes(inRange range: Range<Int>, withBytes bytes: [UInt8]) {
        precondition(range.count == bytes.count)
        replaceSubrange(range, with: Data(bytes))
    }

    mutating func replaceRangeWithPadding(_ range: Range<Int>, with targetValue: String) {
        let targetData = targetValue.data(using: .utf8)!
        precondition(range.count >= targetData.count)
        let targetDataWithPadding = targetData + Array(repeating: UInt8(0), count: range.count - targetData.count)
        assert(range.count == targetDataWithPadding.count)
        replaceSubrange(range, with: targetDataWithPadding)
    }
}
