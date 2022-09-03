//
//  File.swift
//  
//
//  Created by Marin Todorov on 8/31/22.
//

import Foundation

struct MarkEncoding: Encoder {
    let codingPath: CodingPath
    private(set) var userInfo: UserInfo

    var data: CodingData

    init(codingPath: CodingPath, userInfo: UserInfo, to data: CodingData) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(MarkKeyedEncoding<Key>(codingPath: codingPath, userInfo: userInfo, to: data))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // This line adds an empty string to the cell, so in case the collection is empty
        // we still have a column created in the markdown table.
        data.encode(key: codingPath, value: CodingData.listPlaceholder)
        return MarkUnkeyedEncoding(codingPath: codingPath, userInfo: userInfo, to: data)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return MarkSingleValueEncoding(codingPath: codingPath, userInfo: userInfo, to: data)
    }
}

