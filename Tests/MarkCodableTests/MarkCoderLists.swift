// See the LICENSE file for this code's license information.

import XCTest
@testable import MarkCodable

class MarkCoderLists: XCTestCase {

    // Test that lists encode as empty strings.
    func testEmptyLists() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let lists = Lists(
            ints: nil,
            strings: [],
            bools: [],
            optionalBools: [nil],
            custom: [],
            urls: nil
        )

        let encoded = try encoder.encode([lists])
        XCTAssertEqual(encoded, """
        |bools|custom|ints|optionalBools|strings|urls|
        |-----|------|----|-------------|-------|----|
        |     |      |    |nil          |       |    |
        """)

        let decoded = try decoder.decode(Lists.self, from: encoded)
        XCTAssertEqual(decoded, lists)
    }

    // Test lists of various types.
    func testLists() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let lists = Lists(
            ints: [-1, 40, 50],
            strings: ["a", "W", "house"],
            bools: [true, true],
            optionalBools: [false, nil],
            custom: [.read, .execute],
            urls: [URL(string: "https://host")!]
        )

        let encoded = try encoder.encode([lists])
        XCTAssertEqual(encoded, """
        |bools    |custom      |ints    |optionalBools|strings  |urls        |
        |---------|------------|--------|-------------|---------|------------|
        |true,true|read,execute|-1,40,50|false,nil    |a,W,house|https://host|
        """)

        let decoded = try decoder.decode(Lists.self, from: encoded)
        XCTAssertEqual(decoded, lists)
    }

    // Flex coding lists of all kind of numeric values.
    func testAllTheIntsInLists() throws {
        let oneMarkdown = """
        |numbers|
        |-------|
        |1      |
        """

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int8>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int8>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int16>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int16>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int32>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int32>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int64>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int64>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt8>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt8>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt16>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt16>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt32>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt32>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt64>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt64>.self, from: oneMarkdown).numbers)
    }

    // Flex coding lists of various floating point numbers.
    func testFloatNumbersInLists() throws {
        let oneMarkdown = """
        |numbers|
        |-------|
        |1.0    |
        """

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Double>(numbers: [1])))
        XCTAssertEqual([1.0], try decoder.decode(ListContainer<Double>.self, from: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Float>(numbers: [1])))
        XCTAssertEqual([1.0], try decoder.decode(ListContainer<Float>.self, from: oneMarkdown).numbers)
    }

    // Test coding list of strings.
    func testListSingleEmptyString() throws {
        let markdown = """
        |string|
        |------|
        |      |
        """

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        struct SingleString: Codable, Equatable {
            var string: String
        }
        let value = SingleString(string: "")
        XCTAssertEqual(markdown, try encoder.encode(value))
        XCTAssertEqual(value, try decoder.decode(SingleString.self, from: markdown))
    }

}
