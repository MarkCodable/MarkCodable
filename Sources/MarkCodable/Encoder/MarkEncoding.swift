// See the LICENSE file for this code's license information.

import Foundation

struct MarkEncoding: Encoder {
    var breadcrumb: CodingBreadcrumb
    var codingPath: CodingPath { breadcrumb.codingPath }

    private(set) var userInfo: UserInfo
    var data: CodingData

    init(breadcrumb: CodingBreadcrumb, userInfo: UserInfo, to data: CodingData) {
        self.breadcrumb = breadcrumb
        self.userInfo = userInfo
        self.data = data
    }

    func container<Key: CodingKey>(keyedBy type: Key.Type) -> KeyedEncodingContainer<Key> {
        return KeyedEncodingContainer(MarkKeyedEncoding<Key>(breadcrumb: breadcrumb.descendingIntoContainerOfKind(.keyed), userInfo: userInfo, to: data))
    }

    func unkeyedContainer() -> UnkeyedEncodingContainer {
        // This line adds an empty string to the cell, so in case the collection is empty
        // we still have a column created in the markdown table.
        let unkeyedBreadcrumb = breadcrumb.descendingIntoContainerOfKind(.unkeyed)

        // Encoding of the placeholder value can fail silently.
        try? data.encode(breadcrumb: unkeyedBreadcrumb, value: CodingData.listPlaceholder)
        return MarkUnkeyedEncoding(breadcrumb: unkeyedBreadcrumb, userInfo: userInfo, to: data)
    }

    func singleValueContainer() -> SingleValueEncodingContainer {
        return MarkSingleValueEncoding(breadcrumb: breadcrumb.descendingIntoContainerOfKind(.singleValue), userInfo: userInfo, to: data)
    }
}

