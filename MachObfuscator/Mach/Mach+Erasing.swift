import Foundation

extension Image {
    mutating func eraseSymtab() {
        updateMachs { $0.eraseSymtab() }
    }

    mutating func eraseSwiftReflectiveSections() {
        updateMachs { $0.eraseSwiftReflectiveSections() }
    }
}

private extension Mach {
    mutating func eraseSymtab() {
        guard let symtabRange = symtab?.stringTableRange else {
            return
        }
        data.nullify(range: symtabRange.intRange)
    }

    mutating func eraseSwiftReflectiveSections() {
        for section in swiftReflectionSections {
            data.nullify(range: section.range.intRange)
        }
    }
}
