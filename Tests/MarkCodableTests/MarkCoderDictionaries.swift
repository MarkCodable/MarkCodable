// See the LICENSE file for this code's license information.

import XCTest
@testable import MarkCodable

final class MarkCoderDictionaries: XCTestCase {

    // Test dictionary with string keys.
    func testDictionaryCodingStrings() throws {
        struct TestDictionary: Codable, Equatable {
            var name: String
            var pairs: [String: String]
        }

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        // Test encoding keys
        let test = TestDictionary(name: "test", pairs: ["eyes": "blue", "hair": "fair"])
        let result = try encoder.encode(test)
        XCTAssertEqual(result, """
        |name|pairs.eyes|pairs.hair|
        |----|----------|----------|
        |test|blue      |fair      |
        """)

        // Test dictionary roundtrip
        XCTAssertEqual(test, try decoder.decode(TestDictionary.self, from: result))
    }

    // Test dictionary with int keys.
    func testDictionaryCodingInts() throws {
        struct TestDictionary: Codable, Equatable {
            var name: String
            var pairs: [Int: Int]
        }

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        // Test encoding keys
        let test = TestDictionary(name: "test", pairs: [1: 2, 3: 4])
        let result = try encoder.encode(test)
        XCTAssertEqual(result, """
        |name|pairs.1|pairs.3|
        |----|-------|-------|
        |test|2      |4      |
        """)

        // Test dictionary roundtrip
        XCTAssertEqual(test, try decoder.decode(TestDictionary.self, from: result))
    }

    // Test dictionary with URL keys.
    func testDictionaryCodingURLKeys() throws {
        struct TestDictionary: Codable, Equatable {
            var name: String
            var pairs: [URL: Int]
        }

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        // Test encoding keys
        let test = TestDictionary(name: "test", pairs: [URL(string: "https://host")!: 2, URL(string: "/etc/file.var")!: 4])
        let result = try encoder.encode(test)

        // The exact representation as text might vary, testing only the roundtrip
        XCTAssertEqual(test, try decoder.decode(TestDictionary.self, from: result))
    }

    // Test a dictionary coding roundtrip.
    func testTopDictionaryCoding() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let dictionary = ["street": "Main Str.", "number": "100"]
        let markdown = try encoder.encode(dictionary)

        XCTAssertEqual(markdown, """
        |number|street   |
        |------|---------|
        |100   |Main Str.|
        """)

        XCTAssertEqual(dictionary, try decoder.decode([String: String].self, from: markdown))
    }

    // Test dictionaries with varying keys.
    func testTopDictionaryVaryingKeys() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let dictionary1 = ["street": "Main Str.", "number": "100"]
        let dictionary2 = ["street": "Market Str.", "zip": "1745ZD"]

        let markdown = try encoder.encode([dictionary1, dictionary2])

        XCTAssertEqual(markdown, """
        |number|street     |zip   |
        |------|-----------|------|
        |100   |Main Str.  |      |
        |      |Market Str.|1745ZD|
        """)

        let dictionary1Decoded = ["street": "Main Str.", "number": "100", "zip": ""]
        let dictionary2Decoded = ["street": "Market Str.", "zip": "1745ZD", "number": ""]

        XCTAssertEqual([dictionary1Decoded, dictionary2Decoded], try decoder.decode([[String: String]].self, from: markdown))
    }
}
