// See the LICENSE file for this code's license information.

import Foundation

public typealias UserInfo = [CodingUserInfoKey: Any]

typealias CodingValues = [String: String?]
typealias CodingPath = [CodingKey]

enum CoderKind {
    case singleValue, unkeyed, keyed
}

struct CodingBreadcrumb {
    struct Component {
        let key: CodingKey
        var coderKind: CoderKind
    }

    init() { }

    var components: [Component] = []

    var codingPath: [CodingKey] {
        components.map(\.key)
    }

    static var empty: CodingBreadcrumb { return .init() }

    func addingKey(_ key: CodingKey) -> Self {
        var copy = self
        copy.components.append(Component(key: key, coderKind: .singleValue))
        return copy
    }

    func descendingIntoContainerOfKind(_ kind: CoderKind) -> Self {
        var copy = self
        if !copy.components.isEmpty {
            copy.components[copy.components.count-1].coderKind = kind
        }
        return copy
    }
}

extension CodingPath {
    var absoluteString: String {
        map(\.stringValue).joined(separator: ".")
    }
}

typealias Appending = Bool

final class CodingData {
    private(set) var values = CodingValues()
    var isAppendingContainer: [Appending] = [false]
    var isHoldingListPlaceholder = false
    static let listPlaceholder = "ListPlaceholder"
    
    func encode(breadcrumb: CodingBreadcrumb, value: String, appending: Bool = false) throws {
        let codingPath: CodingPath

        if isAppendingContainer.last == true {
            codingPath = breadcrumb.codingPath.dropLast()
        } else {
            codingPath = breadcrumb.codingPath
        }

        // Checks for nested containers in lists.
        if let unkeyedIndex = breadcrumb.components.firstIndex(where: { $0.coderKind == .unkeyed }),
           unkeyedIndex < breadcrumb.components.endIndex - 1 {
            // Check for nested keyed containers
            if breadcrumb.components[unkeyedIndex + 1].coderKind == .keyed {
                throw MarkEncoder.MarkEncodingError.unsupportedNestedContainer("Unsupported keyed container nested in an unkeyed container at path \(breadcrumb.codingPath.absoluteString)")
            }

            // Check for nested unkeyed containers
            if breadcrumb.components[unkeyedIndex + 1].coderKind == .unkeyed {
                throw MarkEncoder.MarkEncodingError.unsupportedNestedContainer("Unsupported unkeyed container nested in an unkeyed container at path \(breadcrumb.codingPath.absoluteString)")
            }
        }

        //print("💎 Encode \(codingPath[codingPath.count-1].stringValue)='\(value)' \(breadcrumb.components.map(\.coderKind).map{ String(describing: $0) }.joined(separator: ","))")
        
        if isHoldingListPlaceholder && value != Self.listPlaceholder {
            isHoldingListPlaceholder = false
            values[codingPath.absoluteString] = value
            return
        }
        
        if value == Self.listPlaceholder {
            isHoldingListPlaceholder = true
            values[codingPath.absoluteString] = ""
            return
        }
        
        if values.keys.contains(codingPath.absoluteString) && (appending || isAppendingContainer.last!) {
            values[codingPath.absoluteString]!! += "," + value
        } else {
            values[codingPath.absoluteString] = value
        }
    }

    private var trackedKeys = [String]()
    func addTrackedKey(_ key: String) {
        trackedKeys.append(key)
    }

    func validateTrackedKeys() throws {
        for trackedKey in trackedKeys where !values.keys.contains(trackedKey) {
            throw MarkEncoder.MarkEncodingError.unsupportedValue("Warning: MarkCodable encountered a code path \(trackedKey) but no values were coded under that key.")
        }
    }

    static var empty: CodingData { return .init() }
}

extension Array where Element == Appending {
    mutating func push(_ value: Element) { append(value) }
    mutating func pop() { removeLast() }
}
