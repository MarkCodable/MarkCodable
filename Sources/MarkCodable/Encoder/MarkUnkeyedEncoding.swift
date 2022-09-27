// See the LICENSE file for this code's license information.

import Foundation

struct MarkUnkeyedEncoding: UnkeyedEncodingContainer {
    var breadcrumb: CodingBreadcrumb
    var codingPath: CodingPath { breadcrumb.codingPath }

    var userInfo = UserInfo()
    private(set) var data = CodingData()

    var count: Int { data.values.count }

    init(breadcrumb: CodingBreadcrumb, userInfo: UserInfo, to data: CodingData) {
        self.breadcrumb = breadcrumb
        self.userInfo = userInfo
        self.data = data
    }

    mutating func encodeNil() throws {
        try data.encode(breadcrumb: breadcrumb.addingKey(IndexCodingKey(count)), value: "nil")
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let markEncoding = MarkEncoding(breadcrumb: breadcrumb.addingKey(IndexCodingKey(count)), userInfo: userInfo, to: data)

        switch value {
        case let url as URL:
            // Encode URLs as plain absolute URLs
            try data.encode(breadcrumb: breadcrumb, value: url.absoluteString, appending: true)
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
        return MarkEncoding(breadcrumb: breadcrumb, userInfo: userInfo, to: data)
    }
}

struct IndexCodingKey: CodingKey {
    init?(stringValue: String) { fatalError() }
    init?(intValue: Int) { fatalError() }

    var intValue: Int?
    var stringValue: String { String(intValue!) }

    init(_ index: Int) {
        intValue = index
    }
}
