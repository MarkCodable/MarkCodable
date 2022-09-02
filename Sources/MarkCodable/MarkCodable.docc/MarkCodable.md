# ``MarkCodable``

A Markdown Swift coding with an eye on human interaction.

## Overview

MarkCodable encodes `Codable` values as Markdown text and decodes Markdown strings as Swift values. Markdown-representation allows humans to easily edit values by hand using their favorite text editor on any operating system or in a web interface.

JSON is flexible but either too compact or too verbose to edit meaningfully by hand:

```javascript
[{"number":134,"street":"main st.","isSocial":false,"price":{"price":1234.3199999999999,"currency":"USD"}},{"number":24,"street":"Secondary st.","isSocial":true,"price":{"price":9234.3199999999997,"currency":"JPY"}}]
```

In comparison, Markdown isn't as expressive but it's far simpler to view and edit by a human:

```text
|isSocial|number|price.currency|price.price|street       |
|--------|------|--------------|-----------|-------------|
|false   |134   |USD           |1234.32    |main st.     |
|true    |24    |JPY           |9234.32    |Secondary st.|
```

Thus, for the smaller scope of encoding data in an edit-friendly format, Markdown is a great choice. 

## Topics

### Getting Started

- <doc:GettingStarted>

### Markdown Coding

- ``MarkEncoder``
- ``MarkDecoder``
