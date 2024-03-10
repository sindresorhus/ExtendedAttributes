import Foundation
import System

/**
Manage system-specific metadata.

Use the ``Foundation/URL/systemMetadata`` property on a URL to access this class.

```swift
import ExtendedAttributes

let fileURL = URL(fileURLWithPath: "/path/to/file")
let itemCreator = try? fileURL.systemMetadata.get(kMDItemCreator as String)
```

- [Supported metadata names](https://developer.apple.com/documentation/coreservices/file_metadata/mditem/common_metadata_attribute_keys)
- [Better descriptions for the names](http://helios.de/support/manuals/indexsrvUB2-e/search_metadata.html)

*System-specific metadata are [extended attributes](https://en.wikipedia.org/wiki/Extended_file_attributes) used on Apple's platforms. They are encoded as property lists and their names are namespaced under `com.apple.metadata:`. This class handles all that for you.*
*/
public final class SystemMetadata {
	private let extendedAttributes: ExtendedAttributes

	init(url: URL) {
		self.extendedAttributes = url.extendedAttributes
	}

	/**
	Retrieves the value of the metadata item specified by the given name.

	- Parameter name: The name of the metadata item.
	- Returns: The metadata item value or `nil` if it does not exist.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func get<T>(_ name: String, type: T.Type) throws -> T? {
		try extendedAttributes.getPropertyListSerializedValue("com.apple.metadata:\(name)", type: type)
	}

	// - flags: Optional flags to specify behavior of the metadata item.
	/**
	Sets the value of the metadata item specified by the given name.

	- Parameters:
		- name: The name of the metadata item.
		- value: The value to be written.
	- Throws: An error if the file is not accessible or the operation fails.

	The following metadata names show up in the Finder "Get Info" window:
	- `kMDItemDescription`
	- `kMDItemHeadline`
	- `kMDItemInstructions`
	- `kMDItemWhereFroms`
	- `kMDItemKeywords`
	*/
	public func set(
		_ name: String,
		value: some Any
		// Finder does not yet support the flags so we leave them out for now: https://eclecticlight.co/2020/11/02/controlling-metadata-tricks-with-persistence/
		//flags: ExtendedAttributes.Flags? = nil
	) throws {
		try extendedAttributes.setPropertyListSerializedValue(
			"com.apple.metadata:\(name)",
			value: value
//			flags: flags
		)
	}

	/**
	Checks whether the file has a metadata item with the given name.

	- Parameter name: The name of the metadata item.
	- Returns: `true` if the metadata item exists, otherwise `false`.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func has(_ name: String) throws -> Bool {
		try extendedAttributes.has("com.apple.metadata:\(name)")
	}

	/**
	Removes the metadata item specified by the given name.

	- Parameter name: The name of the metadata item.
	- Throws: An error if the file is not accessible or the operation fails. It does not throw if the metadata item does not exist.
	*/
	public func remove(_ name: String) throws {
		try extendedAttributes.remove("com.apple.metadata:\(name)")
	}
}

extension URL {
	/**
	Provides convenient access to system-specific metadata of the file/folder at the URL.

	See ``SystemMetadata`` for the API documentation.
	*/
	public var systemMetadata: SystemMetadata { .init(url: self) }
}
