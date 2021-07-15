@testable import App
import XCTest

class Image_updateMachs_Tests: XCTestCase {
    func test_shouldUpdateFlatMach() {
        // Given
        var sut = try! Image.load(url: URL.machoMacExecutable)

        // Then
        sut.updateMachs { mach in
            mach.data[0] = 0x42
        }

        // Then
        guard case let .mach(mach) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        XCTAssertEqual(mach.data[0], 0x42)
    }

    func test_shouldUpdateFatImage() {
        // Given
        var sut = try! Image.load(url: URL.fatIosExecutable)

        // When
        sut.updateMachs { mach in
            mach.data[0] = 0x42
        }

        // Then
        guard case let .fat(fat) = sut.contents else {
            XCTFail("Unexpected contents")
            return
        }
        fat.architectures.forEach { arch in
            XCTAssertEqual(arch.mach.data[0], 0x42)
            XCTAssertEqual(fat.data[Int(arch.offset)], 0x42)
        }
    }
}
