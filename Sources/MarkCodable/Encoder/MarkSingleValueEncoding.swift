// See the LICENSE file for this code's license information.

import Foundation

struct MarkSingleValueEncoding: SingleValueEncodingContainer {
    var breadcrumb: CodingBreadcrumb
    var codingPath: CodingPath { breadcrumb.codingPath }

    var userInfo = UserInfo()
    private(set) var data = CodingData()

    init(breadcrumb: CodingBreadcrumb, userInfo: UserInfo, to data: CodingData) {
        self.breadcrumb = breadcrumb
        self.userInfo = userInfo
        self.data = data
    }

    mutating func encodeNil() throws {
        try data.encode(breadcrumb: breadcrumb, value: "nil")
    }

    mutating func encode<T>(_ value: T) throws where T : Encodable, T : StringInitializable {
        try data.encode(breadcrumb: breadcrumb, value: String(describing: value))
    }

    // TODO: Extract this logic into a reusable function
    // https://github.com/icanzilb/MarkCodable/issues/10
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        let markEncoding = MarkEncoding(breadcrumb: breadcrumb, userInfo: userInfo, to: data)

        switch value {
        case let url as URL:
            data.isAppendingContainer.push(false)
            defer { data.isAppendingContainer.pop() }

            try data.encode(breadcrumb: breadcrumb, value: url.absoluteString)
        default:
            try value.encode(to: markEncoding)
        }
    }
}
