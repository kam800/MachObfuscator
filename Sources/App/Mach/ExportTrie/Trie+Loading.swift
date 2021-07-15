import Foundation

extension Trie {
    init(data: Data, rootNodeOffset: Int) {
        self.init(data: data, rootNodeOffset: rootNodeOffset, nodeOffset: rootNodeOffset, label: [], labelRange: 0 ..< 0)
    }

    private init(data: Data, rootNodeOffset: Int, nodeOffset: Int, label: [UInt8], labelRange: Range<UInt64>) {
        precondition(labelRange.count == label.count)
        self.label = label
        self.labelRange = labelRange
        (exportsSymbol, children) = data.withUnsafeBytes { (bytes: UnsafeRawBufferPointer) -> (Bool, [Trie]) in
            var cursorPtr = bytes.baseAddress!.advanced(by: nodeOffset) // cursorPtr at node start
            let terminalSize = cursorPtr.readUleb128() // cursorPtr after terminal size
            let exportsSymbol = terminalSize != 0
            cursorPtr = cursorPtr.advanced(by: Int(terminalSize)) // cursorPtr at children count
            let childrenCount = cursorPtr.load(as: UInt8.self)
            cursorPtr = cursorPtr.advanced(by: 1) // cursorPtr at first child count
            var children: [Trie] = []
            for _ in 0 ..< childrenCount {
                let childLabelStart = bytes.baseAddress!.distance(to: cursorPtr)
                let childLabel = cursorPtr.readStringBytes()
                let childLabelRange = Range(offset: UInt64(childLabelStart), count: UInt64(childLabel.count))
                precondition(childLabelRange.upperBound <= data.count)
                let childOffset = rootNodeOffset + Int(cursorPtr.readUleb128())
                children.append(Trie(data: data, rootNodeOffset: rootNodeOffset, nodeOffset: childOffset, label: childLabel, labelRange: childLabelRange))
            }
            return (exportsSymbol, children)
        }
    }
}
