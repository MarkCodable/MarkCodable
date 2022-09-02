//
//  File.swift
//  
//
//  Created by Marin Todorov on 9/1/22.
//

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

struct Lists: Codable, Equatable {
    var ints: [Int]
    var strings: [String]
    var bools: [Bool]
    var optionalBools: [Bool?]
    var blogs: [Blog]
    var nestedList: [[Int]]
}
