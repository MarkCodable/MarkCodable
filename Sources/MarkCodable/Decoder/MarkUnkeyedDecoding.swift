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

    mutating func decode(_ type: Bool.Type) throws -> Bool { return try unbox() }
    mutating func decode(_ type: String.Type) throws -> String { return try unbox() }
    mutating func decode(_ type: Double.Type) throws -> Double { return try unbox() }
    mutating func decode(_ type: Float.Type) throws -> Float { return try unbox() }
    mutating func decode(_ type: Int.Type) throws -> Int { return try unbox() }
    mutating func decode(_ type: Int8.Type) throws -> Int8 { return try unbox() }
    mutating func decode(_ type: Int16.Type) throws -> Int16 { return try unbox() }
    mutating func decode(_ type: Int32.Type) throws -> Int32 { return try unbox() }
    mutating func decode(_ type: Int64.Type) throws -> Int64 { return try unbox() }
    mutating func decode(_ type: UInt.Type) throws -> UInt { return try unbox() }
    mutating func decode(_ type: UInt8.Type) throws -> UInt8 { return try unbox() }
    mutating func decode(_ type: UInt16.Type) throws -> UInt16 { return try unbox() }
    mutating func decode(_ type: UInt32.Type) throws -> UInt32 { return try unbox() }
    mutating func decode(_ type: UInt64.Type) throws -> UInt64 { return try unbox() }

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

        // TODO: Is this even correct?
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
        // TODO: nested containers in lists, unsupported
        fatalError()
    }

    mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
        // TODO: nested lists in lists, unsupported
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
