// See the LICENSE file for this code's license information.
#if canImport(Combine)
import XCTest
import Combine
@testable import MarkCodable

final class CombineMarkCodableTests: XCTestCase {
    func testEncoding() throws {
        // Encode values
        var result = [String]()

        _ = [1, 2, 3].publisher
            .map(Simple.init(number:))
            .encode(encoder: MarkEncoder())
            .collect()
            .sink { _ in } receiveValue: {
                result = $0
            }

        let expected = [
            "|number|string|\n|------|------|\n|1     |1     |",
            "|number|string|\n|------|------|\n|2     |2     |",
            "|number|string|\n|------|------|\n|3     |3     |"
        ]

        XCTAssertEqual(expected, result)
    }

    func testDecoding() throws {
        // Decode values
        let markdown = [
            "|number|string|\n|------|------|\n|1     |1     |",
            "|number|string|\n|------|------|\n|2     |2     |",
            "|number|string|\n|------|------|\n|3     |3     |"
        ]

        var result = [Simple]()

        _ = markdown.publisher
            .decode(type: Simple.self, decoder: MarkDecoder())
            .collect()
            .sink(receiveCompletion: { _ in }, receiveValue: {
                result = $0
            })

        XCTAssertEqual(result,  [1, 2, 3].map(Simple.init(number:)))
    }
}
#endif
