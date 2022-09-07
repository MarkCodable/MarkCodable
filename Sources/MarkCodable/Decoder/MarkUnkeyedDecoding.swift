//
//  File.swift
//  
//
//  Created by Marin Todorov on 9/3/22.
//

import Foundation

struct MarkUnkeyedDecoding: UnkeyedDecodingContainer {

    private(set) var codingPath: [CodingKey]
    var userInfo: UserInfo
    private(set) var values: [String]

    var count: Int? { values.count }
    private(set) var currentIndex: Int = 0
    var isAtEnd: Bool { self.currentIndex >= self.count! }

    private var topLevelValues: CodingValues

    init(codingPath: CodingPath, userInfo: UserInfo, from values: [String], topLevelValues: CodingValues) {
        self.codingPath = codingPath
        self.userInfo = userInfo
        self.values = values
        self.topLevelValues = topLevelValues
    }

    private func guardAtEnd() throws {
        guard !self.isAtEnd else {
            throw DecodingError.valueNotFound(Any?.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Unkeyed container is at end decoding index \(currentIndex) of \(count!)."))
        }
    }

    mutating func decodeNil() throws -> Bool {
        try guardAtEnd()

        if values[currentIndex].trimmingCharacters(in: .whitespaces).isEmpty {
            currentIndex += 1
            return true
        } else {
            return false
        }
    }

    mutating func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        try guardAtEnd()

        switch T.self {
        case is URL.Type:
            guard let url = URL(string: values[currentIndex]) else {
                throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse URL value for key \(codingPath)"))
            }
            currentIndex += 1
            return url as! T
        default: break
        }

        let decoding = MarkDecoding(codingPath: codingPath, userInfo: userInfo, from: [codingPath.map(\.stringValue).joined(separator: "."): values[currentIndex]])
        let result = try T.init(from: decoding)
        currentIndex += 1
        return result
    }

    private func unbox<T: Decodable & StringInitializable>() throws -> T {
        try guardAtEnd()

        let value = values[currentIndex]

        guard let result = T(value) else {
            throw DecodingError.typeMismatch(T.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Expected \(T.self) value at \(codingPath)"))
        }
        return result
    }

    mutating func nestedContainer<NestedKey>(keyedBy type: NestedKey.Type) throws -> KeyedDecodingContainer<NestedKey> where NestedKey : CodingKey {
        // Nesting containers isn't supported and this code path can't be hit.
        fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        // Nesting lists isn't supported and this code path can't be hit.
        fatalError()
    }

    mutating func superDecoder() throws -> Decoder {
        return MarkDecoding(codingPath: codingPath + [StringCodingKey(stringValue: "super")!], userInfo: userInfo, from: topLevelValues)
    }
}

struct StringCodingKey: CodingKey {
    let intValue: Int? = nil
    let stringValue: String

    init?(intValue: Int) { fatalError() }

    init?(stringValue: String) {
        self.stringValue = stringValue
    }
}
