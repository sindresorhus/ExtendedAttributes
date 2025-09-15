# ExtendedAttributes

> Manage [extended attributes](https://en.wikipedia.org/wiki/Extended_file_attributes) in Swift

## Install

Add the following to `Package.swift`:

```swift
.package(url: "https://github.com/sindresorhus/ExtendedAttributes", from: "1.0.0")
```

[Or add the package in Xcode.](https://developer.apple.com/documentation/xcode/adding-package-dependencies-to-your-app)

## Usage

```swift
import ExtendedAttributes

let fileURL = URL(filePath: "/path/to/file")
let data = try? fileURL.extendedAttributes.get("com.example.attribute")
```

You can also use it to access system-specific metadata:

```swift
import ExtendedAttributes

let fileURL = URL(filePath: "/path/to/file")
let itemCreator = try? fileURL.systemMetadata.get(kMDItemCreator as String)
```

## API

See the [documentation](https://swiftpackageindex.com/sindresorhus/ExtendedAttributes/documentation/extendedattributes).

## Related

- [Defaults](https://github.com/sindresorhus/Defaults) - Swifty and modern UserDefaults
- [KeyboardShortcuts](https://github.com/sindresorhus/KeyboardShortcuts) - Add user-customizable global keyboard shortcuts to your macOS app
- [More…](https://github.com/search?q=user%3Asindresorhus+language%3Aswift+archived%3Afalse&type=repositories)
