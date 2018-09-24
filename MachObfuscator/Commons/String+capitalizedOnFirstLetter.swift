import Foundation

extension String {
    var capitalizedOnFirstLetter: String {
        return prefix(1).capitalized + dropFirst()
    }
}
