//
//  File.swift
//  
//
//  Created by Marin Todorov on 9/3/22.
//

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

    func decode(_ type: Bool.Type) throws -> Bool { try unbox() }
    func decode(_ type: String.Type) throws -> String { try unbox() }
    func decode(_ type: Double.Type) throws -> Double { try unbox() }
    func decode(_ type: Float.Type) throws -> Float { try unbox() }
    func decode(_ type: Int.Type) throws -> Int { try unbox() }
    func decode(_ type: Int8.Type) throws -> Int8 { try unbox() }
    func decode(_ type: Int16.Type) throws -> Int16 { try unbox() }
    func decode(_ type: Int32.Type) throws -> Int32 { try unbox() }
    func decode(_ type: Int64.Type) throws -> Int64 { try unbox() }
    func decode(_ type: UInt.Type) throws -> UInt { try unbox() }
    func decode(_ type: UInt8.Type) throws -> UInt8 { try unbox() }
    func decode(_ type: UInt16.Type) throws -> UInt16 { try unbox() }
    func decode(_ type: UInt32.Type) throws -> UInt32 { try unbox() }
    func decode(_ type: UInt64.Type) throws -> UInt64 { try unbox() }

    func decode<T>(_ type: T.Type) throws -> T where T : Decodable {
        switch T.self {
        case is URL.Type:
            guard let url = URL(string: value) else {
                throw DecodingError.typeMismatch(URL.self, DecodingError.Context(codingPath: codingPath, debugDescription: "Could not parse URL value for key \(codingPath)"))
            }
            return url as! T
        default: break
        }

        // TODO: Is this even correct?
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
