import XCTest
@testable import vnk_swift

class KeyMappingTests: XCTestCase {
    static var allTests : [(String, (KeyMappingTests) -> () throws -> Void)] {
        return [
            // ("testExample", testExample),
        ]
    }

    func testExample() {
        let keyMapping = KeyMapping()
        // let output = keyMapping.receiveChar(Array("a".utf16)[0])
        XCTAssertNotNil(keyMapping , "PASS")
        // XCTAssertEqual(output, [], "should returns empty array")
    }
}
