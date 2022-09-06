//
//  File.swift
//  
//
//  Created by Marin Todorov on 9/1/22.
//

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
}

#if compiler(>=5.7)
extension Array<Appending> {
    mutating func push(_ value: Element) { append(value) }
    mutating func pop() { removeLast() }
}
#elseif compiler(>=5.6)
extension Array where Element == Bool {
    mutating func push(_ value: Element) { append(value) }
    mutating func pop() { removeLast() }
}
#else
fatalError("This version of MarkCodable requires Swift >= 5.6.")
#endif
