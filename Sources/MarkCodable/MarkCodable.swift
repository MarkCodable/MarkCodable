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
    var isAppendingValues = false
    private(set) var values = CodingValues()

    func encode(key codingKey: CodingPath, value: String) {
        let key = codingKey.map { $0.stringValue }.joined(separator: ".")
        if values.keys.contains(key) && isAppendingValues {
            values[key]!! += "," + value
        } else {
            values[key] = value
        }
    }
}
