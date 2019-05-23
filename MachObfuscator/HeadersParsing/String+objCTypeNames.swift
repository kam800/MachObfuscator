import Foundation

private let interfaceNameRegexp = try! NSRegularExpression(pattern: "@interface\\s+(\\w+)\\b", options: [])
private let protocolNameRegexp = try! NSRegularExpression(pattern: "@protocol\\s+(\\w+)\\b", options: [])
private let classNameRegexp = try! NSRegularExpression(pattern: "@class\\s+(.*);", options: [])
private let wordRegexp = try! NSRegularExpression(pattern: "(\\w+)\\b", options: [])

extension String {
    var objCTypeNames: [String] {
        let headerWithoutComments = withoutComments
        let allLines = headerWithoutComments.components(separatedBy: "\n")
        let typeLines = allLines.filter { $0.contains("@interface") || $0.contains("@protocol") || $0.contains("@class") }
        return typeLines.flatMap { $0.objCTypesFromTypeLine }
    }

    private var objCTypesFromTypeLine: [String] {
        return
            (objCInterfaceNamesFromTypeLine.flatMap { [$0] } ?? [])
            + (objCProtocolNamesFromTypeLine.flatMap { [$0] } ?? [])
            + objCClassNamesFromTypeLine
    }

    private var objCInterfaceNamesFromTypeLine: String? {
        return self[interfaceNameRegexp, 1]
    }

    private var objCProtocolNamesFromTypeLine: String? {
        return self[protocolNameRegexp, 1]
    }

    private var objCClassNamesFromTypeLine: [String] {
        guard let matchingClassBody = self[classNameRegexp, 1] else {
            return []
        }
        return matchingClassBody
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) }
            .compactMap { $0[wordRegexp, 1] }
    }
}
