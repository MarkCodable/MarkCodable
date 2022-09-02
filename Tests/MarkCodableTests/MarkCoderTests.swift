import XCTest
@testable import MarkCodable

final class MarkCoderTests: XCTestCase {
    func testEmpty() throws {
        let encoder = MarkEncoder()
        XCTAssertTrue(encoder.userInfo.isEmpty)

        let decoder = MarkDecoder()
        XCTAssertTrue(decoder.userInfo.isEmpty)
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
}
