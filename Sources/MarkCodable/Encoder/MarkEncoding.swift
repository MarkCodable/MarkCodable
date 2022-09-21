// See the LICENSE file for this code's license information.

import Foundation

struct MarkEncoding: Encoder {
    let codingPath: CodingPath
    private(set) var userInfo: UserInfo

    var data: CodingData

    public enum EncodingType {
        case singleValue
        case unkeyed
    }
    
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
    
    func encode<T>(_ value: T, for encodingType: EncodingType) throws where T : Encodable {
        switch value {
        case let url as URL:
            if encodingType == .singleValue {
                data.isAppendingContainer.push(false)
                defer { data.isAppendingContainer.pop() }
            }
            
            data.encode(key: codingPath, value: url.absoluteString, appending: encodingType == .unkeyed)
        default:
            if encodingType == .unkeyed {
                data.isAppendingContainer.push(true)
                defer { data.isAppendingContainer.pop() }
            }
            
            try value.encode(to: self)
        }
    }
}

