// See the LICENSE file for this code's license information.

import Foundation

// Houses

let house1 = House(
    isNewlyBuilt: true,
    name: "villa Sunshine",
    numberFloors: 2,
    streetNumber: 200,
    numberWindows: 20,
    numberChimneys: 2,
    purchasePrice: 12020.12,
    maintenancePrice: 320.12
)
let house2 = House(
    isNewlyBuilt: false,
    name: "Brick Wonder",
    numberFloors: 10000,
    streetNumber: 1,
    numberWindows: 2,
    numberChimneys: 300,
    purchasePrice: 24_900_435.42,
    maintenancePrice: 13_320.19
)

// Optional houses

let optionalHouse1 = OptionalHouse(
    isNewlyBuilt: true,
    name: "villa Sunshine",
    numberFloors: 2,
    streetNumber: 200,
    numberWindows: 20,
    numberChimneys: 2,
    purchasePrice: 12020.12,
    maintenancePrice: 320.12
)
let optionalNilHouse = OptionalHouse(
    isNewlyBuilt: nil,
    name: nil,
    numberFloors: nil,
    streetNumber: nil,
    numberWindows: nil,
    numberChimneys: nil,
    purchasePrice: nil,
    maintenancePrice: nil
)

// Blogs

let blog1 = Blog(
    address: URL(string: "https://daringfireball.net")!,
    pageNotFound: URL(string: "https://daringfireball.net/zxcglj/#fragment?param=1")!
)
