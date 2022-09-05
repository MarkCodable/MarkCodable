# MarkCodable

Markdown Swift coding with an eye on human interaction.

> This library is still in flux until we find together what's the best way to use markdown encoding, check the issues and/or leave some feedback.

## Overview

**MarkCodable** encodes `Codable` values as Markdown text and decodes Markdown strings as Swift values. Markdown-representation allows humans to easily edit values by hand using their favorite text editor on any operating system or in a web interface.

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

## Use cases

You encode or decode `Codable` values as with any other decoder, bar some limitations on nested data types:

```swift
// Encode into a Markdown string
let markdown = try MarkEncoder().encode([house1, house2])

// Decode from a Markdown string
let houses = try MarkDecoder()
    .decode([House].self, string: markdown)
```

### Configuration

Markdown is a viable alternative to json or yml files, especially for multiple configuration entries like per-environment or per-domain configurations, for example:

```text
| environment | host      | port | user | schema |
|-------------|-----------|------|------|--------|
| qa          | 127.0.0.1 | 8080 | test | http   |
| production  | 2.317.1.2 | 9999 | app  | https  |
```

### Test and mock objects

In unit tests you often times need a number of test objects to create the test setup. Those are sometimes a bit clunky to always create in code so you can either include the Markdown in your tests or have it as an `.md` file in your test bundle:

```text
| userID | name | age | permissions |
|--------|------|-----|-------------|
|1       |peter | 32  |read         |
|2       |admin | 100 |read,write   |
```

### Database

For simple relational data, using `MarkCodable` will allow you or your users to simply edit the data in any plain text editor. This is how a small podcast database might look like:

```text
Users.md:
| userID | name |
|--------|------|
|1       | John |
|2       | Gui  |

Podcasts.md:
| podcastID | name            | hosts |
|-----------|-----------------|-------|
|1          |Swift by Sundell | 1     |
|2          |Stacktrace       | 1,2   |
```

Load the items by reading the files, decoding the values, and optionally store them as indexed dictionaries:

```swift
let users = try MarkDecoder()
    .decode([User].self, string: String(contentsOfFile: "Users.md"))
    .reduce(into: [Int: User](), { $0[$1.id] = $1 })

print(users[2]) // [userID: 2, name: Gui]
```

## Installation

Use the package directly in Xcode or via SwiftPM:

```swift
dependencies: [
  .package(url: "https://github.com/icanzilb/MarkCodable", from: "0.6.0"),
]
```

## Demo App

This package contains a target called `marktest` that showcases some demo code. Run that demo from the package folder via:

```text
swift run marktest
```

To see a demo of a full SwiftUI app (~70 lines of Swift) using a GitHub-hosted Markdown file as backend, check out [this repo](https://github.com/icanzilb/MarkCodingDemoApp).

<img src="https://raw.githubusercontent.com/icanzilb/MarkCodingDemoApp/main/etc/app-screen.png" width=320>

## Credits

MIT License, Marin Todorov (2022)

[@icanzilb on Twitter](https://twitter.com/icanzilb)

## Help, feedback or suggestions?

- There is a list of current [bugs](https://github.com/icanzilb/MarkCodable/issues?q=is%3Aissue+is%3Aopen+label%3Abug) if you'd like to pick one.
- There is also a list of currently planned [enhancements](https://github.com/icanzilb/MarkCodable/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement).


- [Open an issue](https://github.com/icanzilb/MarkCodable/issues) if you need help, if you found a bug, or if you want to discuss a feature request.
- [Open a PR](https://github.com/icanzilb/MarkCodable/pulls) if you want to make a change to the code.
