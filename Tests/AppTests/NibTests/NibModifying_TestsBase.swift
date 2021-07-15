@testable import App
import XCTest

class NibModifying_TestsBase: XCTestCase {
    let sutURL = URL.tempFile
    var sut: Nib!

    func createSut(type: Nib.Type, fromURL url: URL) {
        try! FileManager.default.copyItem(at: url, to: sutURL)
        sut = type.load(from: sutURL)
    }

    override func tearDown() {
        sut = nil
        try! FileManager.default.removeItem(at: sutURL)
        super.tearDown()
    }
}
