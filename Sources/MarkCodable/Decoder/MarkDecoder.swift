// See the LICENSE file for this code's license information.

import Foundation
import Markdown

/// An object that decodes instances of a data type from Markdown text.
///
/// Use a markdown table as the source string to decode one or more Swift `Codable` values, for example:
///
/// ```text
/// |isSocial|number|price.currency|price.price|street    |
/// |--------|------|--------------|-----------|----------|
/// |true    |700   |USD           |2000001.0  |Marine Ave|
/// |true    |25    |EUR           |100400.0   |Main St.  |
/// ```
/// > Note: The table might not be pretty formatted as long as its valid markdown, i.e. the pipes don't need to align vertically.
///
/// Use ``decode(_:from:)-4ek7u`` to decode one or more values:
///
/// ```swift
/// let decoder = MarkDecoder()
/// let houses = try decoder.decode([House].self, from: markdown)
/// ```
public class MarkDecoder {

    /// Any user info to pass along to decoding containers.
    public var userInfo = UserInfo()

    /// Creates a new decoder.
    public init() { }

    /// Markdown decoding errors.
    public enum MarkDecodingError: Error {
        case unexpectedSourceFormat(String)
        case unsupportedFormat(String)
    }

    /// Decodes Markdown to a collection of same-type items.
    ///
    /// The method throws if `string` isn't in the expected Markdown format or any of the values cannot be decoded into its expected data type.
    /// - parameter type: The type of the value to decode from the supplied Markdown.
    /// - parameter string: The source Markdown string.
    /// - returns: An array of items of the given type.
    public func decode<T: Decodable>(_ type: [T].Type, from string: String) throws -> [T]  {
        return try decode(type, string: string, numberResults: Int.max)
    }

    /// Decodes Markdown to an instance of the given data type.
    ///
    /// The method throws if `string` isn't in the expected Markdown format or any of the values cannot be decoded into its expected data type.
    /// - parameter type: The type of the value to decode from the supplied Markdown.
    /// - parameter from: The source Markdown string.
    /// - returns: An instance of the given type.
    @_disfavoredOverload
    public func decode<T: Decodable>(_ type: T.Type, from string: String) throws -> T  {
        return try decode([T].self, string: string, numberResults: 1)[0]
    }
}

private extension MarkDecoder {
    func decode<T: Decodable>(_ type: [T].Type, string: String, numberResults: Int) throws -> [T]  {
        let document = Document(parsing: string, options: [])
        guard let table = document.children.first(where: { markup in
            return markup is Table
        }) as? Table else {
            throw MarkDecodingError.unexpectedSourceFormat("No markdown table element found")
        }

        // Load the keys
        let keys = Array(table.head.cells.map(\.plainText))
        let keyToIndex = keys.reduce(into: [String: Int]()) { partialResult, key in
            partialResult[key] = keys.firstIndex(of: key)!
        }

        // Load the values
        let values: [CodingValues] = table.body.rows.prefix(numberResults).map { row in
            let cells = Array(row.cells)
            return keys.reduce(into: CodingValues()) { partialResult, key in
                partialResult[key] = cells[keyToIndex[key]!].plainText
            }
        }

        guard !values.isEmpty else {
            throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No decodable data found"))
        }

        return try values.map { value in
            let markDecoding = MarkDecoding(userInfo: userInfo, from: value)
            return try T.init(from: markDecoding)
        }
    }
}

#if canImport(Combine)
import Combine

extension MarkDecoder: TopLevelDecoder {
    public typealias Input = String
}
#endif
