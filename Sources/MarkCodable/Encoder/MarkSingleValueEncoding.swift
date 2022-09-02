//
//  File.swift
//  
//
//  Created by Marin Todorov on 9/2/22.
//

import Foundation

struct MarkSingleValueEncoding: SingleValueEncodingContainer {
    private(set) var codingPath: CodingPath
    var userInfo = UserInfo()
    private(set) var data = CodingData()

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

    // TODO: Extract this logic into a reusable function
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let markEncoding = MarkEncoding(codingPath: codingPath, userInfo: userInfo, to: data)

        switch value {
        case let url as URL:
            data.isAppendingContainer.push(false)
            defer { data.isAppendingContainer.pop() }

            data.encode(key: codingPath, value: url.absoluteString)
        default:
            try value.encode(to: markEncoding)
        }
    }
}
