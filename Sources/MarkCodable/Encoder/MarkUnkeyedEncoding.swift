//
//  File.swift
//  
//
//  Created by Marin Todorov on 9/2/22.
//

import Foundation

//struct IndexCodingKey: CodingKey {
//    let intValue: Int?
//    let stringValue: String
//
//    init?(intValue: Int) {
//        self.intValue = intValue
//        self.stringValue = String(intValue)
//    }
//
//    init?(stringValue: String) { fatalError() }
//}

struct MarkUnkeyedEncoding: UnkeyedEncodingContainer {
    private(set) var codingPath: CodingPath
    var userInfo = UserInfo()
    private(set) var data = CodingData()

    var count: Int { data.values.count }
    //var key: CodingKey { IndexCodingKey(intValue: count)! }

    init(codingPath: CodingPath, userInfo: UserInfo, to data: CodingData) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }

    mutating func encodeNil() throws {
        data.encode(key: codingPath, value: "")
    }

    mutating func encode(_ value: Bool) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: String) throws {
        data.encode(key: codingPath, value: value)
    }

    mutating func encode(_ value: Double) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: Float) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: Int) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: Int8) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: Int16) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: Int32) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: Int64) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: UInt) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: UInt8) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: UInt16) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: UInt32) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode(_ value: UInt64) throws {
        data.encode(key: codingPath, value: String(value))
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let markEncoding = MarkEncoding(codingPath: codingPath, userInfo: userInfo, to: data)

        switch value {
        case let url as URL:
            // Encode URLs as plain absolute URLs
            data.encode(key: codingPath, value: url.absoluteString, appending: true)
        default:
            data.isAppendingContainer.push(true)
            defer { data.isAppendingContainer.pop() }

            try value.encode(to: markEncoding)
        }
    }

    mutating func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = MarkKeyedEncoding<NestedKey>(codingPath: codingPath, userInfo: userInfo, to: data)
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        let container = MarkUnkeyedEncoding(codingPath: codingPath, userInfo: userInfo, to: data)
        return container
    }

    mutating func superEncoder() -> Encoder {
        MarkEncoding(codingPath: codingPath, userInfo: userInfo, to: data)
    }
}
