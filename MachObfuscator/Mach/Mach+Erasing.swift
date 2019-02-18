import Foundation

extension Image {
    mutating func eraseSymtab() {
        updateMachs { $0.eraseSymtab() }
    }

    mutating func eraseSwiftReflectiveSections() {
        updateMachs { $0.eraseSwiftReflectiveSections() }
    }

    mutating func eraseMethTypeSection() {
        updateMachs { $0.eraseMethTypeSection() }
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

    mutating func eraseMethTypeSection() {
        guard let methTypeSectionRange = objcMethTypeSection?.range else {
            return
        }

        data.nullify(range: methTypeSectionRange.intRange)
    }
}
