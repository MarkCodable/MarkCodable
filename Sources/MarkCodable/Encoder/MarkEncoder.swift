// See the LICENSE file for this code's license information.

import Foundation
import Markdown

/// An object that encodes instances of a data type as Markdown text.
///
/// Use ``encode(_:)-4uago`` to encode `Codable` compliant values:
///
/// ```swift
/// let encoder = MarkEncoder()
/// let markdown = try encoder.encode(houses)
/// ```
/// The encoded values are represented as text in a Markdown format table:
///
/// ```text
/// |isSocial|number|price.currency|price.price|street    |
/// |--------|------|--------------|-----------|----------|
/// |true    |700   |USD           |2000001.0  |Marine Ave|
/// |true    |25    |EUR           |100400.0   |Main St.  |
/// ```
public class MarkEncoder {
    /// Markdown encoding errors.
    public enum MarkEncodingError: Error {
        case unsupportedValue(String)
        case unsupportedNestedContainer(String)
    }

    /// Any user info to pass along to encoding containers.
    var userInfo = UserInfo()
    
    /// Creates a new encoder instance.
    public init() { }
    
    /// Returns a Markdown-encoded representation of the collection value you supply.
    /// - Parameter value: The value to encode as Markdown.
    /// - Returns: The encoded Markdown text.
    public func encode<T: Encodable>(_ collection: T) throws -> String where T: Collection, T.Element: Encodable {
        var keys = [String]()
        var values = [CodingValues]()
        
        var uniqueKeys = Set<String>()
        
        for value in collection {
            let encoding = MarkEncoding(breadcrumb: .empty, userInfo: userInfo, to: .empty)
            try value.encode(to: encoding)
            uniqueKeys = uniqueKeys.union(encoding.data.values.keys)
            values.append(encoding.data.values)
        }
        keys = uniqueKeys.sorted()
        
        let table = Markdown.Table(
            header: Markdown.Table.Head(
                keys.map { value -> Markdown.Table.Cell in
                    Markdown.Table.Cell(Text(value))
                }
            ),
            body: Markdown.Table.Body(
                values.map({ row -> Markdown.Table.Row in
                    Markdown.Table.Row(
                        keys.map { key -> Markdown.Table.Cell in
                            if let optionalValue = row[key], let value = optionalValue {
                                return Markdown.Table.Cell(Text(value))
                            } else {
                                return Markdown.Table.Cell(Text(""))
                            }
                        }
                    )
                })
            )
        )
        
        return table.format()
    }
    
    /// Returns a Markdown-encoded representation of the value you supply.
    /// - Parameter value: The value to encode as Markdown.
    /// - Returns: The encoded Markdown text.
    public func encode<T: Encodable>(_ value: T) throws -> String {
        var keys = [String]()
        var values = [CodingValues]()
        
        let encoding = MarkEncoding(breadcrumb: .empty, userInfo: userInfo, to: .empty)
        try value.encode(to: encoding)

        // Throws in case not all walked nested container keys ended up encoding values.
        try encoding.data.validateTrackedKeys()

        keys = encoding.data.values.keys.sorted()
        values = [encoding.data.values]
        
        let table = Markdown.Table(
            header: Markdown.Table.Head(
                keys.map { value -> Markdown.Table.Cell in
                    Markdown.Table.Cell(Text(value))
                }
            ),
            body: Markdown.Table.Body(
                values.map({ row -> Markdown.Table.Row in
                    Markdown.Table.Row(
                        keys.map { key -> Markdown.Table.Cell in
                            if let optionalValue = row[key], let value = optionalValue {
                                return Markdown.Table.Cell(Text(value))
                            } else {
                                return Markdown.Table.Cell(Text(""))
                            }
                        }
                    )
                })
            )
        )
        
        return table.format()
    }
}

#if canImport(Combine)
import Combine

extension MarkEncoder: TopLevelEncoder { }
#endif
