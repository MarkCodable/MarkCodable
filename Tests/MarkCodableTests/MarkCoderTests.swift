import XCTest
@testable import MarkCodable

final class MarkCoderTests: XCTestCase {
    func testEmpty() throws {
        let encoder = MarkEncoder()
        XCTAssertTrue(encoder.userInfo.isEmpty)

        let decoder = MarkDecoder()
        XCTAssertTrue(decoder.userInfo.isEmpty)
    }

    func testDecodeUnexpectedInput() {
        let decoder = MarkDecoder()
        let notMarkdown = "not markdown"

        XCTAssertThrowsError(
            try decoder.decode(House.self, string: notMarkdown),
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
            try decoder.decode(House.self, string: wrongMarkdown),
            "Expected to throw an error for missing keys") { error in

                guard case DecodingError.keyNotFound = error else {
                    XCTFail("Unexpected error \(error) thrown")
                    return
                }
            }
    }

    func testCodingKeysDefaultTypes() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let encoded1 = try encoder.encode(house1)
        XCTAssertEqual(encoded1, """
        |isNewlyBuilt|maintenancePrice|name          |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|--------------|--------------|------------|-------------|-------------|------------|
        |true        |320.12          |villa Sunshine|2             |2           |20           |12020.12     |200         |
        """)

        let decoded1 = try decoder.decode(House.self, string: encoded1)
        XCTAssertEqual(decoded1, house1)

        let encoded2 = try encoder.encode(house2)
        XCTAssertEqual(encoded2, """
        |isNewlyBuilt|maintenancePrice|name        |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|------------|--------------|------------|-------------|-------------|------------|
        |false       |13320.19        |Brick Wonder|300           |10000       |2            |24900435.42  |1           |
        """)

        let decoded2 = try decoder.decode(House.self, string: encoded2)
        XCTAssertEqual(decoded2, house2)
    }

    func testMultipleRowsEncodingKeysDefaultTypes() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let encoded1 = try encoder.encode([house1, house2])

        XCTAssertEqual(encoded1, """
        |isNewlyBuilt|maintenancePrice|name          |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|--------------|--------------|------------|-------------|-------------|------------|
        |true        |320.12          |villa Sunshine|2             |2           |20           |12020.12     |200         |
        |false       |13320.19        |Brick Wonder  |300           |10000       |2            |24900435.42  |1           |
        """)

        let decoded1 = try decoder.decode([House].self, string: encoded1)
        XCTAssertEqual(decoded1, [house1, house2])
    }

    func testCodingOptionalKeysDefaultTypes() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let encoded1 = try encoder.encode(optionalHouse1)
        XCTAssertEqual(encoded1, """
        |isNewlyBuilt|maintenancePrice|name          |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|--------------|--------------|------------|-------------|-------------|------------|
        |true        |320.12          |villa Sunshine|2             |2           |20           |12020.12     |200         |
        """)

        let decoded1 = try decoder.decode([OptionalHouse].self, string: encoded1)
        XCTAssertEqual(decoded1, [optionalHouse1])

        var optional = optionalNilHouse
        let encoded2 = try encoder.encode(optional)
        XCTAssertEqual(encoded2, """
        ||
        ||
        ||
        """)

        // TODO: the encoder produces an invalid markdown table
        // https://github.com/icanzilb/MarkCodable/issues/1
        // let decoded2 = try decoder.decode([OptionalHouse].self, string: encoded2)
        // XCTAssertEqual(decoded2, [optional])

        optional.isNewlyBuilt = true
        let encoded3 = try encoder.encode(optional)
        XCTAssertEqual(encoded3, """
        |isNewlyBuilt|
        |------------|
        |true        |
        """)

        let decoded3 = try decoder.decode([OptionalHouse].self, string: encoded3)
        XCTAssertEqual(decoded3, [optional])

        optional.numberWindows = 10_000
        let encoded4 = try encoder.encode(optional)
        XCTAssertEqual(encoded4, """
        |isNewlyBuilt|numberWindows|
        |------------|-------------|
        |true        |10000        |
        """)

        let decoded4 = try decoder.decode([OptionalHouse].self, string: encoded4)
        XCTAssertEqual(decoded4, [optional])
    }

    func testOptionalEncodingKeysDefaultTypes() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let encoded1 = try encoder.encode([optionalHouse1, optionalNilHouse])
        XCTAssertEqual(encoded1, """
        |isNewlyBuilt|maintenancePrice|name          |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|--------------|--------------|------------|-------------|-------------|------------|
        |true        |320.12          |villa Sunshine|2             |2           |20           |12020.12     |200         |
        |            |                |              |              |            |             |             |            |
        """)

        let decoded1 = try decoder.decode([OptionalHouse].self, string: encoded1)
        XCTAssertEqual(decoded1, [optionalHouse1, optionalNilHouse])
    }

    func testCodingKeysCustomTypes() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let encoded1 = try encoder.encode([blog1])
        XCTAssertEqual(encoded1, """
        |address                   |pageNotFound                                       |
        |--------------------------|---------------------------------------------------|
        |https://daringfireball.net|https://daringfireball.net/zxcglj/#fragment?param=1|
        """)

        let decoded1 = try decoder.decode(Blog.self, string: encoded1)
        XCTAssertEqual(decoded1, blog1)
    }

    func testDeterministicFormatting() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        var encoded = try encoder.encode([house1, house2])

        // Does a number of roundtrips.
        for _ in 0...100 {
            let decoded1 = try decoder.decode([House].self, string: encoded)
            XCTAssertEqual(decoded1, [house1, house2])
            let encoded1 = try encoder.encode(decoded1)
            XCTAssertEqual(encoded1, encoded)
            encoded = encoded1
        }
    }

    func testUserInfo() throws {
        let userInfo: MarkCodable.UserInfo = [CodingUserInfoKey(rawValue: "key")!: "value"]

        // Test user info during encoding
        let encoder = MarkEncoder()
        encoder.userInfo = userInfo

        let container = UserInfoContainer()

        XCTAssertNil(container.encodingUserInfo)
        _ = try encoder.encode(container)

        let containerUserInfo = try XCTUnwrap(container.encodingUserInfo)
        XCTAssertEqual(containerUserInfo.count, 1)
        let value = try XCTUnwrap(containerUserInfo[CodingUserInfoKey(rawValue: "key")!] as? String)
        XCTAssertEqual(value, "value")

        // Test user info during decoding
        let decoder = MarkDecoder()
        decoder.userInfo = userInfo

        let decodedContainer = try decoder.decode(UserInfoContainer.self, string: """
        |name|
        |-|
        ||
        """)

        let decodeContainerUserInfo = try XCTUnwrap(decodedContainer.decodingUserInfo)
        XCTAssertEqual(decodeContainerUserInfo.count, 1)
        let decodeValue = try XCTUnwrap(decodeContainerUserInfo[CodingUserInfoKey(rawValue: "key")!] as? String)
        XCTAssertEqual(decodeValue, "value")
    }

    func testAllTheInts() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let ints = AllTheInts(
            int: 1, int8: 2, int16: 3, int32: 4, int64: 5, uint: 6, uint8: 7, uint16: 8, uint32: 9, uint64: 10
        )

        let encoded = try encoder.encode([ints])
        let decoded = try decoder.decode(AllTheInts.self, string: encoded)

        XCTAssertEqual(decoded, ints)
    }

    func testEmptyLists() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let lists = Lists(
            ints: nil,
            strings: [],
            bools: [],
            optionalBools: [nil],
            custom: []
        )

        let encoded = try encoder.encode([lists])
        XCTAssertEqual(encoded, """
        |bools|custom|optionalBools|strings|
        |-----|------|-------------|-------|
        |     |      |nil          |       |
        """)

        let decoded = try decoder.decode(Lists.self, string: encoded)
        XCTAssertEqual(decoded, lists)
    }

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

        let decoded = try decoder.decode(Lists.self, string: encoded)
        XCTAssertEqual(decoded, lists)
    }

    func testAllTheIntsInLists() throws {
        let oneMarkdown = """
        |numbers|
        |-------|
        |1      |
        """

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int8>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int8>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int16>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int16>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int32>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int32>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Int64>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<Int64>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt8>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt8>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt16>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt16>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt32>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt32>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<UInt64>(numbers: [1])))
        XCTAssertEqual([1], try decoder.decode(ListContainer<UInt64>.self, string: oneMarkdown).numbers)
    }

    func testFloatNumbersInLists() throws {
        let oneMarkdown = """
        |numbers|
        |-------|
        |1.0    |
        """

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Double>(numbers: [1])))
        XCTAssertEqual([1.0], try decoder.decode(ListContainer<Double>.self, string: oneMarkdown).numbers)

        XCTAssertEqual(oneMarkdown, try encoder.encode(ListContainer<Float>(numbers: [1])))
        XCTAssertEqual([1.0], try decoder.decode(ListContainer<Float>.self, string: oneMarkdown).numbers)
    }

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
        XCTAssertEqual(value, try decoder.decode(SingleString.self, string: markdown))
    }
}
