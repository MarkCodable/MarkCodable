// See the LICENSE file for this code's license information.

import Foundation

public typealias UserInfo = [CodingUserInfoKey: Any]

typealias CodingValues = [String: String?]
typealias CodingPath = [CodingKey]

extension CodingPath {
    var absoluteString: String { map(\.stringValue).joined(separator: ".") }
}

typealias Appending = Bool

final class CodingData {
    private(set) var values = CodingValues()
    var isAppendingContainer: [Appending] = [false]
    var isHoldingListPlaceholder = false
    static let listPlaceholder = "ListPlaceholder"
    
    func encode(key codingKey: CodingPath, value: String, appending: Bool = false) {
        //print("Encode \(type(of: value)) for key(\(codingKey.count)) \(codingKey.map{"\($0)"}.joined(separator: "."))")
        
        if isHoldingListPlaceholder && value != Self.listPlaceholder {
            isHoldingListPlaceholder = false
            values[codingKey.absoluteString] = value
            return
        }
        
        if value == Self.listPlaceholder {
            isHoldingListPlaceholder = true
            values[codingKey.absoluteString] = ""
            return
        }
        
        if values.keys.contains(codingKey.absoluteString) && (appending || isAppendingContainer.last!) {
            values[codingKey.absoluteString]!! += "," + value
        } else {
            values[codingKey.absoluteString] = value
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
}

extension Array where Element == Appending {
    mutating func push(_ value: Element) { append(value) }
    mutating func pop() { removeLast() }
}
