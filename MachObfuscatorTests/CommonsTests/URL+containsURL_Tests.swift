import XCTest

class URL_containsURL_Tests: XCTestCase {

    func test_shouldContainSelf() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/dir1/nested")

        // Expect
        XCTAssert(url.contains(url))
    }

    func test_shouldContainChild() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/dir1/nested")
        let child = URL(fileURLWithPath: "/tmp/dir1/nested/leaf")

        // Expect
        XCTAssert(url.contains(child))
    }

    func test_shouldNotContainSibling() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/dir1/nested")
        let sibling = URL(fileURLWithPath: "/tmp/dir1/sibling")

        // Expect
        XCTAssertFalse(url.contains(sibling))
    }

    func test_shouldNotContainUnrelated() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/dir1/nested")
        let unrelated = URL(fileURLWithPath: "/tmp/dir2")

        // Expect
        XCTAssertFalse(url.contains(unrelated))
    }

    func test_shouldNotContainUnrelatedChild() {
        // Given
        let url = URL(fileURLWithPath: "/tmp/dir1/nested")
        let unrelated = URL(fileURLWithPath: "/tmp/dir2/nested/leaf")

        // Expect
        XCTAssertFalse(url.contains(unrelated))
    }
}
