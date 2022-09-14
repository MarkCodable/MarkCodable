// See the LICENSE file for this code's license information.

import Foundation

struct MarkKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {

    private(set) var codingPath: CodingPath
    var userInfo = UserInfo()
    private let data: CodingData

    init(codingPath: CodingPath = [], userInfo: UserInfo, to data: CodingData) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }

    // TODO: This is likely needed for all other primitives and requires testing.
    mutating func encodeIfPresent(_ value: String?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }

    mutating func encodeIfPresent<T>(_ value: T?, forKey key: Key) throws where T : Encodable {
        if let value = value {
            try encode(value, forKey: key)
        } else {
            try encodeNil(forKey: key)
        }
    }

    mutating func encodeNil(forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: "")
    }

    mutating func encode<T: Encodable & StringInitializable>(_ value: T, forKey key: Key) throws {
        data.encode(key: codingPath + [key], value: String(describing: value))
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        let markEncoding = MarkEncoding(codingPath: codingPath + [key], userInfo: userInfo, to: data)

        switch value {
        case let url as URL:
            // Encode URLs as plain absolute URLs
            data.encode(key: codingPath + [key], value: url.absoluteString)
        default:
            try value.encode(to: markEncoding)
        }
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        let container = MarkKeyedEncoding<NestedKey>(codingPath: codingPath + [key], userInfo: userInfo, to: data)
        // Track nested containers, as part as a failsafe against enums.
        data.addTrackedKey((codingPath + [key]).absoluteString)
        
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return MarkUnkeyedEncoding(codingPath: codingPath + [key], userInfo: userInfo, to: data)
    }

    mutating func superEncoder() -> Encoder {
        let superKey = Key(stringValue: "super")!
        return superEncoder(forKey: superKey)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        return MarkEncoding(codingPath: codingPath + [key], userInfo: userInfo, to: data)
    }
}
