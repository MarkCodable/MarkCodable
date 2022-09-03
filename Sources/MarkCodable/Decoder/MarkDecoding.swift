//
//  File.swift
//  
//
//  Created by Marin Todorov on 8/31/22.
//

import Foundation

struct MarkDecoding: Decoder {
    let codingPath: CodingPath
    private(set) var data: CodingValues
    let userInfo: UserInfo

    init(codingPath: CodingPath = [], userInfo: UserInfo, from data: CodingValues) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key : CodingKey {
        let container = MarkKeyedDecoding<Key>(codingPath: codingPath, userInfo: userInfo, data: data)
        return KeyedDecodingContainer(container)
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        let value: String
        if let optionalValue = data[codingPath.absoluteString],
              let unwrappedValue = optionalValue {
            value = unwrappedValue
        } else {
            value = ""
        }

        let list = value.isEmpty ? [] : value.components(separatedBy: ",")
        return MarkUnkeyedDecoding(codingPath: codingPath, userInfo: userInfo, from: list, topLevelValues: data)
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        guard let optionalValue = data[codingPath.absoluteString],
              let value = optionalValue else {
            throw DecodingError.keyNotFound(codingPath.last!, DecodingError.Context(codingPath: codingPath, debugDescription: "No value for \(codingPath)"))
        }
        return MarkSingleValueDecoding(codingPath: codingPath, userInfo: userInfo, value: value)
    }
}
