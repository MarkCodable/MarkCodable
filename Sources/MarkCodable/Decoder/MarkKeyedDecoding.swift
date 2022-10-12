// See the LICENSE file for this code's license information.

import Foundation

/// Used to skip empty collections when decoded into an optional field.
fileprivate protocol DecodableCollection {
    var isEmpty: Bool { get }
}

extension Array: DecodableCollection where Element: Decodable { }

struct MarkKeyedDecoding<Key: CodingKey>: KeyedDecodingContainerProtocol {
    var allKeys: [Key] {
        return data.keys.sorted().compactMap { Key(stringValue: $0) }
    }

    func contains(_ key: Key) -> Bool {
        return data.keys.contains(key.stringValue)
    }

    // TODO: This is likely needed for all other primitives and requires testing.
    func decodeIfPresent(_ type: String.Type, forKey key: Key) throws -> String? {
        let decoding = MarkDecoding(codingPath: [key], userInfo: userInfo, from: data)
        let value = try String(from: decoding)
        guard !value.isEmpty else { return nil }
        return value
    }

    func decodeIfPresent<T>(_ type: T.Type, forKey key: Key) throws -> T? where T : Decodable {
        // TODO: Test if we handle optional URL/custom types properly like decode<T>

        var nestedData = CodingValues()
        nestedData.reserveCapacity(data.count)
        
        // If we're descending into a keyed container, strip the rest of the data
        // so that we have only the relevant keys left for dynamic keyed containers.
        if !data.keys.contains(key.stringValue) {
            let prefix = key.stringValue.appending(".")

            for (key, value) in data.filter({ element in
                element.key.hasPrefix(prefix)
            }) {
                nestedData[String(key.dropFirst(prefix.count))] = value
            }
        } else {
            nestedData = data
        }

        let decoding = MarkDecoding(codingPath: [key], userInfo: userInfo, from: nestedData)
        let decodedValue: T

        do {
            decodedValue = try T.init(from: decoding)
        } catch MarkDecoder.MarkDecodingControlFlow.representationForNil {
            // The nil value was represented as text
            return nil
        }

        // Optional collection cells that are empty decode as empty collections, e.g. `[]`. We rather want `nil` instead.
        if let collectionDecodable = decodedValue as? DecodableCollection,
           collectionDecodable.isEmpty {
            return nil
        }

        return decodedValue
    }

    func decodeNil(forKey key: Key) throws -> Bool {
        guard let value = data[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: [key], debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        return value == ""
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable, T: StringInitializable {
        return try unbox(key)
    }

    func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T : Decodable {
        switch T.self {
        case is URL.Type:
            guard let optionalValue = data[key.stringValue], // TODO: Add tests if nestedPath is needed
                  let value = optionalValue,
                  let url = URL(string: value) else {
                throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse URL value for key \(codingPath)"))
            }
            return url as! T
        default: break
        }

        var nestedData = CodingValues()
        nestedData.reserveCapacity(data.count)

        if !data.keys.contains(key.stringValue) {
            let prefix = key.stringValue.appending(".")

            for (key, value) in data.filter({ element in
                element.key.hasPrefix(prefix)
            }) {
                nestedData[String(key.dropFirst(prefix.count))] = value
            }
        } else {
            nestedData = data
        }

        let decoding = MarkDecoding(codingPath: [key], userInfo: userInfo, from: nestedData)
        return try T.init(from: decoding)
    }

    func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type, forKey key: Key) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        let container = MarkKeyedDecoding<NestedKey>(codingPath: codingPath, userInfo: userInfo, data: data)
        return KeyedDecodingContainer(container)
    }

    func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
        let nestedPath = codingPath + [key]
        guard let optionalValue = data[nestedPath.absoluteString],
              let value = optionalValue else {
            throw DecodingError.keyNotFound(nestedPath.last!, DecodingError.Context(codingPath: nestedPath, debugDescription: "No value for \(nestedPath.absoluteString)"))
        }

        let list = value.isEmpty ? [] : value.components(separatedBy: ",")
        return MarkUnkeyedDecoding(codingPath: codingPath, userInfo: userInfo, from: list, topLevelValues: data)
    }

    func superDecoder() throws -> Decoder {
        let superKey = Key(stringValue: "super")!
        return try superDecoder(forKey: superKey)
    }

    func superDecoder(forKey key: Key) throws -> Decoder {
        return MarkDecoding(codingPath: codingPath + [key], userInfo: userInfo, from: data)
    }

    private let data: CodingValues
    private(set) var codingPath: CodingPath = []
    var userInfo = UserInfo()

    init(codingPath: CodingPath = [], userInfo: UserInfo, data: CodingValues) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.data = data
    }

    private func unbox<T: Decodable & StringInitializable>(_ key: Key) throws -> T {
        guard let value = data[key.stringValue] else {
            throw DecodingError.keyNotFound(key, DecodingError.Context(codingPath: codingPath, debugDescription: "No value associated with key \(key) (\"\(key.stringValue)\")."))
        }
        guard let unwrappedValue = value else {
            fatalError()
        }

        guard let result = T(unwrappedValue) else {
            throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Unexpected value '\(String(describing: value))' of type \(T.self)")
        }
        return result
    }
}

protocol StringInitializable {
    init?(_ source: String)
}

extension Int: StringInitializable {}
extension Int8: StringInitializable {}
extension Int16: StringInitializable {}
extension Int32: StringInitializable {}
extension Int64: StringInitializable {}
extension UInt: StringInitializable {}
extension UInt8: StringInitializable {}
extension UInt16: StringInitializable {}
extension UInt32: StringInitializable {}
extension UInt64: StringInitializable {}
extension Double: StringInitializable {}
extension Float: StringInitializable {}
extension Bool: StringInitializable {}
extension String: StringInitializable {}
