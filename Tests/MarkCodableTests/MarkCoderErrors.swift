// See the LICENSE file for this code's license information.

import XCTest
@testable import MarkCodable

final class MarkCoderErrors: XCTestCase {

    // Test invalid markdown and unexpected structure.
    func testDecodeUnexpectedInput() {
        let decoder = MarkDecoder()
        let notMarkdown = "not markdown"

        XCTAssertThrowsError(
            try decoder.decode(House.self, from: notMarkdown),
            "Expected to throw an error for unexpected input") { error in

                guard case MarkDecoder.MarkDecodingError.unexpectedSourceFormat = error else {
                    XCTFail("Unexpected error \(error) thrown")
                    return
                }
            }

        let wrongMarkdown = """
        | amount |
        |--------|
        |123     |
        """

        XCTAssertThrowsError(
            try decoder.decode(House.self, from: wrongMarkdown),
            "Expected to throw an error for missing keys") { error in

                guard case DecodingError.keyNotFound = error else {
                    XCTFail("Unexpected error \(error) thrown")
                    return
                }
            }
    }

    // Test that encoding a struct inside array throws an error.
    func testNestedKeyedContainerInListThrows() throws {
        struct First: Codable {
            struct Second: Codable {
                let id: Int
                let name: String
            }

            let ints: [Int]
            let list: [Second]
        }

        let model = First(
            ints: [1],
            list: [.init(id: 3, name: "name3")]
        )

        XCTAssertThrowsError(try MarkEncoder().encode(model), "Didn't throw for nested keyed containers in a list") { error in
            guard case MarkEncoder.MarkEncodingError.unsupportedNestedContainer = error else {
                return XCTFail("Threw an unexpected \(error) while encoding")
            }
        }
    }

    // Test that encoding an array inside array throws an error.
    func testNestedUnkeyedContainerInListThrows() throws {
        struct First: Codable {
            let ints: [[Int]]
        }

        let model = First(
            ints: [[1]]
        )

        XCTAssertThrowsError(try MarkEncoder().encode(model), "Didn't throw for nested unkeyed containers in a list") { error in
            guard case MarkEncoder.MarkEncodingError.unsupportedNestedContainer = error else {
                return XCTFail("Threw an unexpected \(error) while encoding")
            }
        }
    }

}
