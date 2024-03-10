# ``ExtendedAttributes``

Extended attributes allow storage of additional metadata beyond the standard filesystem attributes, such as custom data, security information, or system tags.

## Usage

```swift
import ExtendedAttributes

let fileURL = URL(fileURLWithPath: "/path/to/file")
let data = try? fileURL.extendedAttributes.get("com.example.attribute")
```

You can also use it to access system-specific metadata:

```swift
import ExtendedAttributes

let fileURL = URL(fileURLWithPath: "/path/to/file")
let itemCreator = try? fileURL.systemMetadata.get(kMDItemCreator as String)
```

---

[Learn more about extended attributes](https://en.wikipedia.org/wiki/Extended_file_attributes)
