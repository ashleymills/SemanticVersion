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
    }
    
    func testInitString() throws {
        var sv = try XCTUnwrap(SemanticVersion("6"))
        XCTAssertEqual(sv.description, "6.0.0")
        sv = try XCTUnwrap(SemanticVersion("0.3"))
        XCTAssertEqual(sv.description, "0.3.0")
        sv = try XCTUnwrap(SemanticVersion("10.3.87"))
        XCTAssertEqual(sv.description, "10.3.87")

        XCTAssertNil(SemanticVersion(""))
        XCTAssertNil(SemanticVersion("1."))
        XCTAssertNil(SemanticVersion(".1"))
        XCTAssertNil(SemanticVersion("-"))
        XCTAssertNil(SemanticVersion("a.b"))
        XCTAssertNil(SemanticVersion("..."))
        XCTAssertNil(SemanticVersion("."))

        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.0.0")).description, "1.0.0")
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("0.0.0")).description, "0.0.0")
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.2.0")).description, "1.2.0")
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1")).description, "1.0.0")
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.2")).description, "1.2.0")
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.2.3")).description, "1.2.3")

        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.2.3")).majorString, "1")
        XCTAssertEqual(try XCTUnwrap(SemanticVersion("1.2.3")).minorString, "1.2")
    }
    
    func testInitPreRelease() throws {
        var sv = try XCTUnwrap(SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["alpha"]))
        XCTAssertEqual(sv.description, "1.0.0-alpha")            
        sv = try XCTUnwrap(SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["alpha", "1"]))
        XCTAssertEqual(sv.description, "1.0.0-alpha.1")            
        sv = try XCTUnwrap(SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["0","3","7"]))
        XCTAssertEqual(sv.description, "1.0.0-0.3.7")            
        sv = try XCTUnwrap(SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["x","7","z","92"]))
        XCTAssertEqual(sv.description, "1.0.0-x.7.z.92")            

        XCTAssertNil(SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["alpha&"]))
        XCTAssertNil(SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["0alpha"]))
    }

    func testInitPreReleaseString() throws {
        XCTAssertNil(SemanticVersion("1.0.0-"))
        
        var sv = try XCTUnwrap(SemanticVersion("1.0.0-alpha"))
        XCTAssertEqual(sv.description, "1.0.0-alpha")            
        sv = try XCTUnwrap(SemanticVersion("1.0.0-alpha.1"))
        XCTAssertEqual(sv.description, "1.0.0-alpha.1")            
        sv = try XCTUnwrap(SemanticVersion("1.0.0-0.3.7"))
        XCTAssertEqual(sv.description, "1.0.0-0.3.7")            
        sv = try XCTUnwrap(SemanticVersion("1.0.0-x.7.z.92"))
        XCTAssertEqual(sv.description, "1.0.0-x.7.z.92") 
        sv = try XCTUnwrap(SemanticVersion("1.0.0-x-y-z.–"))
        XCTAssertEqual(sv.description, "1.0.0-x-y-z.–")     
    }
    
    func testCodable() throws {
        do {
            let sv = SemanticVersion(major: 10, minor: 3, patch: 87)
            let data = try JSONEncoder().encode(sv)
            let sv2 = try JSONDecoder().decode(SemanticVersion.self, from: data)
            XCTAssertEqual(sv, sv2)
        }
        do {
            let sv = SemanticVersion(major: 1, minor: 0, patch: 0, preRelease: ["alpha"])
            let data = try JSONEncoder().encode(sv)
            let sv2 = try JSONDecoder().decode(SemanticVersion.self, from: data)
            XCTAssertEqual(sv, sv2)
        }
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
