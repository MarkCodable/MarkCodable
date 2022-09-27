// See the LICENSE file for this code's license information.

import XCTest
@testable import MarkCodable

final class MarkCoderEnums: XCTestCase {

    // Test that the encoder throws for non raw-value enum cases.
    func testPlainEnumsThrowError() throws {
        // Enum with and without associated values.
        struct TestStruct: Codable {
            enum Kind: Codable {
                case basic(String, Int), intermediate
            }
            var kind: Kind
        }

        let encoder = MarkEncoder()
        let test1 = TestStruct(kind: .intermediate)

        XCTAssertThrowsError(try encoder.encode(test1), "Didn't throw for enum property") { error in
            guard case MarkEncoder.MarkEncodingError.unsupportedValue(let message) = error else {
                XCTFail("Didn't throw expected error")
                return
            }
            guard message.contains("kind.intermediate") else {
                XCTFail("Error message didn't contain the coding path")
                return
            }
        }

        let test2 = TestStruct(kind: .basic("asd", 133))
        XCTAssertThrowsError(try encoder.encode(test2), "Didn't throw for enum property") { error in
            guard case MarkEncoder.MarkEncodingError.unsupportedValue(let message) = error else {
                XCTFail("Didn't throw expected error")
                return
            }
            guard message.contains("kind.basic") else {
                XCTFail("Error message didn't contain the coding path")
                return
            }
        }
    }

    // Test that the codec handles raw representable cases.
    func testRawValueEnums() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        struct TestStruct: Codable, Equatable {
            // String representable case.
            enum Kind: String, Codable, CaseIterable {
                case basic, intermediate, advanced
            }

            // Int representable case.
            enum Count: Int, Codable, CaseIterable {
                case low = 1
                case high = 100
            }
            var kind: Kind
            var count: Count
        }

        // Test enum cases encode correctly as values.
        let test1 = TestStruct(kind: .intermediate, count: .high)
        let result = try encoder.encode(test1)
        XCTAssertEqual(result, """
        |count|kind        |
        |-----|------------|
        |100  |intermediate|
        """)

        // Test that enum values roundtrip successfully.
        for kind in TestStruct.Kind.allCases {
            for count in TestStruct.Count.allCases {
                let test = TestStruct(kind: kind, count: count)
                let result = try encoder.encode(test)
                let roundtrip = try decoder.decode(TestStruct.self, from: result)
                XCTAssertEqual(roundtrip, test)
            }
        }
    }

    // Test that the codec handles enum cases with custom coding.
    func testCustomCodingEnums() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        struct TestStruct: Codable, Equatable {
            // Cases with custom coding
            enum Kind: Codable, Equatable {
                case none, url(String)

                func encode(to encoder: Encoder) throws {
                    var container = encoder.singleValueContainer()
                    switch self {
                    case .none: try container.encode("none")
                    case .url(let string): try container.encode(string)
                    }
                }

                init(from decoder: Decoder) throws {
                    let value = try decoder.singleValueContainer().decode(String.self)
                    self = value == "none" ? .none : .url(value)
                }
            }
            var kind1: Kind
            var kind2: Kind
        }

        // Test enum cases encode correctly as values.
        let test1 = TestStruct(kind1: .none, kind2: .url("http://host"))
        let result = try encoder.encode(test1)
        XCTAssertEqual(result, """
        |kind1|kind2      |
        |-----|-----------|
        |none |http://host|
        """)

        // Test roundtrip.
        XCTAssertEqual(test1, try decoder.decode(TestStruct.self, from: result))
    }
}
