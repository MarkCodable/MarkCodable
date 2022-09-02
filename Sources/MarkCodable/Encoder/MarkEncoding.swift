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

    init(codingPath: CodingPath = [], userInfo: UserInfo, to data: CodingData) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        let container = MarkKeyedEncoding<Key>(codingPath: codingPath, userInfo: userInfo, to: data)
        return KeyedEncodingContainer(container)
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError()
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        fatalError()
    }
}

