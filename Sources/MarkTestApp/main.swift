// See the LICENSE file for this code's license information.

import Foundation
import MarkCodable

/// Test data model
struct House: Codable {
    var isSocial = true
    var street: String
    var number: Int
    var price: Price

    struct Price: Codable {
        var amount: Double
        var currency: String
        var conversionRate: Float?
    }
}

// Markdown input
let input = """
| street | number | price.amount | price.currency | isSocial | price.conversionRate |
|----------| ------ | ---| --- | -- | - |
| main st. | 134 | 1234.32 | USD | false     | |
| Secondary st. | 24 | 9234.32 | JPY | true| 24.28 |
"""

print()
print("1️⃣  Markdown source text:")
print(input)
print()

// Decode values
let decoder = MarkDecoder()
let houses = try decoder.decode([House].self, from: input)

print("2️⃣  Decoded structs:")
dump(houses)
print()

// Encode values
let encoder = MarkEncoder()
let output = try encoder.encode(houses)

print("3️⃣  Re-encoded structs as text:")
print(output)
print()

print("Done.")
