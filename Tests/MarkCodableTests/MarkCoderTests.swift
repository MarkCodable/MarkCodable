// See the LICENSE file for this code's license information.

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

    func testCodingKeysDefaultTypes() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let encoded1 = try encoder.encode(house1)
        XCTAssertEqual(encoded1, """
        |isNewlyBuilt|maintenancePrice|name          |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|--------------|--------------|------------|-------------|-------------|------------|
        |true        |320.12          |villa Sunshine|2             |2           |20           |12020.12     |200         |
        """)

        let decoded1 = try decoder.decode(House.self, from: encoded1)
        XCTAssertEqual(decoded1, house1)

        let encoded2 = try encoder.encode(house2)
        XCTAssertEqual(encoded2, """
        |isNewlyBuilt|maintenancePrice|name        |numberChimneys|numberFloors|numberWindows|purchasePrice|streetNumber|
        |------------|----------------|------------|--------------|------------|-------------|-------------|------------|
        |false       |13320.19        |Brick Wonder|300           |10000       |2            |24900435.42  |1           |
        """)

        let decoded2 = try decoder.decode(House.self, from: encoded2)
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

        let decoded1 = try decoder.decode([House].self, from: encoded1)
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

        let decoded1 = try decoder.decode([OptionalHouse].self, from: encoded1)
        XCTAssertEqual(decoded1, [optionalHouse1])

        var optional = optionalNilHouse
        let encoded2 = try encoder.encode(optional)
        XCTAssertEqual(encoded2, """
        |name|
        |----|
        |    |
        """)

        let decoded2 = try decoder.decode([OptionalHouse].self, from: encoded2)
        XCTAssertEqual(decoded2, [optional])

        optional.isNewlyBuilt = true
        let encoded3 = try encoder.encode(optional)
        XCTAssertEqual(encoded3, """
        |isNewlyBuilt|name|
        |------------|----|
        |true        |    |
        """)

        let decoded3 = try decoder.decode([OptionalHouse].self, from: encoded3)
        XCTAssertEqual(decoded3, [optional])

        optional.numberWindows = 10_000
        let encoded4 = try encoder.encode(optional)
        XCTAssertEqual(encoded4, """
        |isNewlyBuilt|name|numberWindows|
        |------------|----|-------------|
        |true        |    |10000        |
        """)

        let decoded4 = try decoder.decode([OptionalHouse].self, from: encoded4)
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

        let decoded1 = try decoder.decode([OptionalHouse].self, from: encoded1)
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

        let decoded1 = try decoder.decode(Blog.self, from: encoded1)
        XCTAssertEqual(decoded1, blog1)
    }

    func testDeterministicFormatting() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        var encoded = try encoder.encode([house1, house2])

        // Does a number of roundtrips.
        for _ in 0...100 {
            let decoded1 = try decoder.decode([House].self, from: encoded)
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

        let decodedContainer = try decoder.decode(UserInfoContainer.self, from: """
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
        let decoded = try decoder.decode(AllTheInts.self, from: encoded)

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

    // TODO: Add variants for all other encodable primites to verify we correctly produce a column header even when there's no data.
    func testSingleOptionalStringColumn() throws {
        struct SingleOptionalString: Codable, Equatable {
            var optionalString: String?
        }

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        let singleNilMarkdown = """
        |optionalString|
        |--------------|
        |              |
        """
        let nilValue = SingleOptionalString(optionalString: nil)
        XCTAssertEqual(singleNilMarkdown, try encoder.encode(nilValue))
        XCTAssertEqual(nilValue, try decoder.decode(SingleOptionalString.self, from: singleNilMarkdown))

        let singleNonNilMarkdown = """
        |optionalString|
        |--------------|
        |yes           |
        """
        let existingValue = SingleOptionalString(optionalString: "yes")
        XCTAssertEqual(singleNonNilMarkdown, try encoder.encode(existingValue))
        XCTAssertEqual(existingValue, try decoder.decode(SingleOptionalString.self, from: singleNonNilMarkdown))

        let multipleNilsMarkdown = """
        |optionalString|
        |--------------|
        |              |
        |              |
        |              |
        """
        let multipleNilValues = [
            SingleOptionalString(optionalString: nil),
            SingleOptionalString(optionalString: nil),
            SingleOptionalString(optionalString: nil),
        ]
        XCTAssertEqual(multipleNilsMarkdown, try encoder.encode(multipleNilValues))
        XCTAssertEqual(multipleNilValues, try decoder.decode([SingleOptionalString].self, from: multipleNilsMarkdown))

        let multipleMixedMarkdown = """
        |optionalString|
        |--------------|
        |              |
        |mixed         |
        |              |
        """
        let multipleMixedValues = [
            SingleOptionalString(optionalString: nil),
            SingleOptionalString(optionalString: "mixed"),
            SingleOptionalString(optionalString: nil),
        ]
        XCTAssertEqual(multipleMixedMarkdown, try encoder.encode(multipleMixedValues))
        XCTAssertEqual(multipleMixedValues, try decoder.decode([SingleOptionalString].self, from: multipleMixedMarkdown))
    }

    func testNestedTypes() throws {
        let markdown = """
        |optionalPig.color|optionalPig.name|pig.color|pig.name|
        |-----------------|----------------|---------|--------|
        |pink             |Snowball        |         |Napoleon|
        """

        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        XCTAssertEqual(try encoder.encode(animalFarm1), markdown)
        XCTAssertEqual(try decoder.decode(AnimalFarm.self, from: markdown), animalFarm1)
    }

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
                XCTFail("Error message didn't contain the codingpath")
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
                XCTFail("Error message didn't contain the codingpath")
                return
            }
        }
    }

    func testRawValueEnums() throws {
        let encoder = MarkEncoder()
        let decoder = MarkDecoder()

        struct TestStruct: Codable, Equatable {
            // String representable case
            enum Kind: String, Codable, CaseIterable {
                case basic, intermediate, advanced
            }

            // Int representable case
            enum Count: Int, Codable, CaseIterable {
                case low = 1
                case high = 100
            }
            var kind: Kind
            var count: Count
        }

        // Test enum cases encode correctly as values
        let test1 = TestStruct(kind: .intermediate, count: .high)
        let result = try encoder.encode(test1)
        XCTAssertEqual(result, """
        |count|kind        |
        |-----|------------|
        |100  |intermediate|
        """)

        // Test that enum values roundtrip successfully
        for kind in TestStruct.Kind.allCases {
            for count in TestStruct.Count.allCases {
                let test = TestStruct(kind: kind, count: count)
                let result = try encoder.encode(test)
                let roundtrip = try decoder.decode(TestStruct.self, from: result)
                XCTAssertEqual(roundtrip, test)
            }
        }
    }

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

        // Test enum cases encode correctly as values
        let test1 = TestStruct(kind1: .none, kind2: .url("http://host"))
        let result = try encoder.encode(test1)
        XCTAssertEqual(result, """
        |kind1|kind2      |
        |-----|-----------|
        |none |http://host|
        """)

        // Test roundtrip
        XCTAssertEqual(test1, try decoder.decode(TestStruct.self, from: result))
    }

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
}
