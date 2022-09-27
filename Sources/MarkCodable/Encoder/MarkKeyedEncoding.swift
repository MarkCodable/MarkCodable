// See the LICENSE file for this code's license information.

import Foundation

struct MarkKeyedEncoding<Key: CodingKey>: KeyedEncodingContainerProtocol {
    var breadcrumb: CodingBreadcrumb
    var codingPath: CodingPath { breadcrumb.codingPath }

    var userInfo = UserInfo()
    private let data: CodingData

    init(breadcrumb: CodingBreadcrumb = .empty, userInfo: UserInfo, to data: CodingData) {
        self.breadcrumb = breadcrumb
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
        try data.encode(breadcrumb: breadcrumb.addingKey(key), value: "")
    }

    mutating func encode<T: Encodable & StringInitializable>(_ value: T, forKey key: Key) throws {
        try data.encode(breadcrumb: breadcrumb.addingKey(key), value: String(describing: value))
    }

    mutating func encode<T: Encodable>(_ value: T, forKey key: Key) throws {
        let markEncoding = MarkEncoding(breadcrumb: breadcrumb.addingKey(key), userInfo: userInfo, to: data)

        switch value {
        case let url as URL:
            // Encode URLs as plain absolute URLs
            try data.encode(breadcrumb: markEncoding.breadcrumb, value: url.absoluteString)
        default:
            try value.encode(to: markEncoding)
        }
    }

    mutating func nestedContainer<NestedKey: CodingKey>(
        keyedBy keyType: NestedKey.Type,
        forKey key: Key
    ) -> KeyedEncodingContainer<NestedKey> {
        let container = MarkKeyedEncoding<NestedKey>(breadcrumb: breadcrumb.addingKey(key), userInfo: userInfo, to: data)
        // Track nested containers, as part as a failsafe against enums.
        data.addTrackedKey((codingPath + [key]).absoluteString)
        
        return KeyedEncodingContainer(container)
    }

    mutating func nestedUnkeyedContainer(forKey key: Key) -> UnkeyedEncodingContainer {
        return MarkUnkeyedEncoding(breadcrumb: breadcrumb.addingKey(key), userInfo: userInfo, to: data)
    }

    mutating func superEncoder() -> Encoder {
        let superKey = Key(stringValue: "super")!
        return superEncoder(forKey: superKey)
    }

    mutating func superEncoder(forKey key: Key) -> Encoder {
        return MarkEncoding(breadcrumb: breadcrumb.addingKey(key), userInfo: userInfo, to: data)
    }
}
