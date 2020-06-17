import XCTest
@testable import SemanticVersion

final class SemanticVersionTests: XCTestCase {
    func testInit() {
        var sv = SemanticVersion(major: 6)
        XCTAssertEqual(sv.description, "6.0.0")
        sv = SemanticVersion(major: 0, minor: 3)
        XCTAssertEqual(sv.description, "0.3.0")
        sv = SemanticVersion(major: 10, minor: 3, patch: 87)
        XCTAssertEqual(sv.description, "10.3.87")

        XCTAssertNil(SemanticVersion(""))
        XCTAssertNil(SemanticVersion("1."))
        XCTAssertNil(SemanticVersion(".1"))
        XCTAssertNil(SemanticVersion("-"))
        XCTAssertNil(SemanticVersion("a.b"))
        XCTAssertNil(SemanticVersion("..."))
        XCTAssertNil(SemanticVersion("."))

        XCTAssertEqual(SemanticVersion("1.0.0")?.description, "1.0.0")
        XCTAssertEqual(SemanticVersion("0.0.0")?.description, "0.0.0")
        XCTAssertEqual(SemanticVersion("1.2.0")?.description, "1.2.0")
        XCTAssertEqual(SemanticVersion("1")?.description, "1.0.0")
        XCTAssertEqual(SemanticVersion("1.2")?.description, "1.2.0")
        XCTAssertEqual(SemanticVersion("1.2.3")?.description, "1.2.3")

        XCTAssertEqual(SemanticVersion("1.2.3")?.majorString, "1")
        XCTAssertEqual(SemanticVersion("1.2.3")?.minorString, "1.2")
    }

    func testCompare() {
        XCTAssertEqual(SemanticVersion("1.2.3"), SemanticVersion(major: 1, minor: 2, patch: 3))
        XCTAssertEqual(SemanticVersion(major: 1, minor: 2), SemanticVersion(major: 1, minor: 2, patch: 0))

        XCTAssertLessThan(SemanticVersion("1.2.3")!, SemanticVersion("1.2.4")!)
        XCTAssertLessThan(SemanticVersion("1.3.3")!, SemanticVersion("1.4.0")!)
        XCTAssertLessThan(SemanticVersion("2.3.3")!, SemanticVersion("3.0.0")!)

        XCTAssertGreaterThan(SemanticVersion(major: 1), SemanticVersion(major: 0, minor: 9))
    }

    func testDecode() throws {
        struct Result: Decodable {
            let version: SemanticVersion
        }

        do {
            let data = Data(#"{"version": "1.0"}"#.utf8)
            let result = try JSONDecoder().decode(Result.self, from: data)
            XCTAssertEqual(result.version, SemanticVersion("1.0"))
        }

        do {
            let data = Data(#"{"version": "x.0"}"#.utf8)
            XCTAssertThrowsError(try JSONDecoder().decode(Result.self, from: data))
        }
    }

    static var allTests = [
        ("testInit", testInit), ("testCompare", testCompare),
    ]
}
