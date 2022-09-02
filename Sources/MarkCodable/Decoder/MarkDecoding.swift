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
        throw MarkDecoder.MarkDecodingError.unsupportedFormat("Unexpected collection value at key \(codingPath)")
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        throw MarkDecoder.MarkDecodingError.unsupportedFormat("Unexpected value at key \(codingPath)")
    }
}
