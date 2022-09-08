// See the LICENSE file for this code's license information.

import Foundation

struct MarkSingleValueDecoding: SingleValueDecodingContainer {
    private(set) var codingPath: CodingPath
    var userInfo = UserInfo()
    private(set) var value: String

    init(codingPath: CodingPath, userInfo: UserInfo, value: String) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.value = value
    }

    func decodeNil() -> Bool {
        return value == "nil"
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable, T: StringInitializable {
        return try unbox()
    }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch T.self {
        case is URL.Type:
            guard let url = URL(string: value) else {
                throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse URL value for key \(codingPath)"))
            }
            return url as! T
        default: break
        }

        let decoding = MarkDecoding(codingPath: codingPath, userInfo: userInfo, from: [codingPath.map(\.stringValue).joined(separator: "."): value])
        return try T.init(from: decoding)
    }

    private func unbox<T: Decodable & StringInitializable>() throws -> T {
        guard let result = T(value) else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(T.self) value at \(codingPath)"))
        }
        return result
    }
}
