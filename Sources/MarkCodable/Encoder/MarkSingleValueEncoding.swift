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
        data.encode(key: codingPath, value: "nil")
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable, T : StringInitializable {
        data.encode(key: codingPath, value: String(describing: value))
    }

    // TODO: Extract this logic into a reusable function
    // https://github.com/icanzilb/MarkCodable/issues/10
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
