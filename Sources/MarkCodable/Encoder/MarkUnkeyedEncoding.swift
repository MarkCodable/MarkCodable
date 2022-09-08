// See the LICENSE file for this code's license information.

import Foundation

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
        data.encode(key: codingPath, value: "nil")
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
        // Nesting containers isn't supported by MarkCodable.
        fatalError("Nesting containers isn't supported")
    }

    mutating func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        // Nesting lists isn't supported by MarkCodable.
        fatalError("Nesting lists isn't supported")
    }

    mutating func superEncoder() -> Encoder {
        MarkEncoding(codingPath: codingPath, userInfo: userInfo, to: data)
    }
}
