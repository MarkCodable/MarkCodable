# Encode and decode as Markdown

Get started with the Mark encoder and decoder.

## Overview

Use ``MarkEncoder`` and ``MarkDecoder`` similarly to other coders provided by the Foundation framework like `JSONEncoder` or `PropertyListEncoder` to encode and decode data.

The Markdown encoding uses a flat table-like representation so there are some limits to what Swift structures will be encoded, the limitations stemming mostly in the fact whether the string representation can be meaningfully edited by a human in a plain text editor.

The supported types are all scalar types adopting `Codable` by default.

> Note: Currently dictionaries and arrays are not supported.

## Encoding

To encode Swift values as Markdown start by defining a `Codable` compliant structure or a class:

```swift
struct House: Codable {
    var isSocial = true
    var street: String
    var number: Int
    var price: Price
    
    struct Price: Codable {
        var price: Double
        var currency: String
        var conversionRate: Float?
    }
}
```

Then, create instance(s) of that model and use ``MarkEncoder/encode(_:)-4uago`` to get a Markdown representation as a string:

```swift
let house = House(
    street: "Main St.",
    number: 25,
    price: .init(
        price: 100_400,
        currency: "EUR"
    )
)

let encoder = MarkEncoder()
let markdown = try encoder.encode(house)
```

Now `markdown` contains the following text:

```text
|isSocial|number|price.currency|price.price|street  |
|--------|------|--------------|-----------|--------|
|true    |25    |EUR           |100400.0   |Main St.|
```

## Decoding

To decode Swift values from a Markdown string use ``MarkDecoder/decode(_:from:)-17h8g``.

Let's assume you have a string containing the following text:

```text
|isSocial|number|price.currency|price.price|street    |
|--------|------|--------------|-----------|----------|
|true    |700   |USD           |2000001.0  |Marine Ave|
|true    |25    |EUR           |100400.0   |Main St.  |
```

Decode the house values from that Markdown by using ``MarkDecoder``:

```swift
let houses = try MarkDecoder().decode([House].self, from: markdown)
```
