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

final class CodingData {
    private(set) var values = CodingValues()
    var isAppendingContainer: [Bool] = [false]

    func encode(key codingKey: CodingPath, value: String, appending: Bool = false) {
        //print("Encode \(type(of: value)) for key(\(codingKey.count)) \(codingKey.map{"\($0)"}.joined(separator: "."))")

        let key = codingKey.map { $0.stringValue }.joined(separator: ".")
        if values.keys.contains(key) && (appending || isAppendingContainer.last!) {
            values[key]!! += "," + value
        } else {
            values[key] = value
        }
    }
}

extension Array where Element == Bool {
    mutating func push(_ value: Element) { append(value) }
    mutating func pop() { removeLast() }
}
