// See the LICENSE file for this code's license information.

import Foundation
import MarkCodable

struct House: Codable, Equatable {
    var isNewlyBuilt: Bool
    var name: String
    var numberFloors: Int
    var streetNumber: UInt
    var numberWindows: Int64
    var numberChimneys: UInt64
    var purchasePrice: Double
    var maintenancePrice: Float
}

struct OptionalHouse: Codable, Equatable {
    var isNewlyBuilt: Bool?
    var name: String?
    var numberFloors: Int?
    var streetNumber: UInt?
    var numberWindows: Int64?
    var numberChimneys: UInt64?
    var purchasePrice: Double?
    var maintenancePrice: Float?
}

struct Blog: Codable, Equatable {
    var address: URL
    var pageNotFound: URL
}

class UserInfoContainer: Codable {
    var encodingUserInfo: MarkCodable.UserInfo?
    var decodingUserInfo: MarkCodable.UserInfo?

    var name: String = ""

    init() { }

    enum CodingKeys: CodingKey {
        case name
    }

    func encode(to encoder: Encoder) throws {
        encodingUserInfo = encoder.userInfo

        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
    }

    required init(from decoder: Decoder) throws {
        decodingUserInfo = decoder.userInfo

        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
    }
}

struct AllTheInts: Codable, Equatable {
    var int: Int
    var int8: Int8
    var int16: Int16
    var int32: Int32
    var int64: Int64
    var uint: UInt
    var uint8: UInt8
    var uint16: UInt16
    var uint32: UInt32
    var uint64: UInt64
}

enum Permission: Codable {
    case read, write, execute

    enum CodingKeys: CodingKey {
        case read, write, execute
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .read: try container.encode("read")
        case .write: try container.encode("write")
        case .execute: try container.encode("execute")
        }
    }

    enum Errors: Error { case unexpectedValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let string = try container.decode(String.self)
        switch string {
        case "read": self = .read
        case "write": self = .write
        case "execute": self = .execute
        default: throw Errors.unexpectedValue
        }
    }
}

struct Lists: Codable, Equatable {
    var ints: [Int]?
    var strings: [String]
    var bools: [Bool]
    var optionalBools: [Bool?]
    var custom: [Permission]
    var urls: [URL]? = nil
}

struct ListContainer<T: Codable>: Codable {
    let numbers: Array<T>
}

struct AnimalFarm: Codable, Equatable {
    let pig: Pig

    struct Pig: Codable, Equatable {
        let name: String
    }
}
