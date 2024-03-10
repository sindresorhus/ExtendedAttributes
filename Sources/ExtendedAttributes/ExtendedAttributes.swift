import Foundation
import System

/**
Manage extended attributes.

Use the ``Foundation/URL/extendedAttributes`` property on a URL to access this class.

```swift
import ExtendedAttributes

let fileURL = URL(fileURLWithPath: "/path/to/file")
let data = try? fileURL.extendedAttributes.get("com.example.attribute")
```
*/
public final class ExtendedAttributes {
	private let url: URL

	init(url: URL) {
		self.url = url
	}

	/**
	Retrieves the value of the extended attribute specified by the given name.

	- Parameter name: The name of the attribute.
	- Returns: The attribute value or `nil` if it does not exist.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func get(_ name: String) throws -> Data? {
		do {
			return try _get(name)
		} catch Errno.attributeNotFound {
			return nil
		}
	}

	/**
	Sets the value of the extended attribute specified by the given name.

	- Parameters:
		- name: The name of the attribute.
		- data: The data to be written as the value of the attribute.
		- flags: Optional flags to specify behavior of the attribute setting.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func set(_ name: String, data: Data, flags: Flags? = nil) throws {
		try checkIfFileURL()

		let finalName = if let flags {
			try Self.nameWithFlags(name, flags: flags)
		} else {
			name
		}

		try url.withUnsafeFileSystemRepresentation { fileSystemPath in
			try Errno.wrap {
				data.withUnsafeBytes {
					setxattr(fileSystemPath, finalName, $0.baseAddress, data.count, 0, 0)
				}
			}
		}
	}

	/**
	Checks whether the file has an extended attribute with the given name.

	- Parameter name: The name of the attribute.
	- Returns: `true` if the attribute exists, otherwise `false`.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func has(_ name: String) throws -> Bool {
		try checkIfFileURL()

		return try url.withUnsafeFileSystemRepresentation { fileSystemPath in
			let size = getxattr(fileSystemPath, name, nil, 0, 0, 0)

			if size >= 0 {
				return true
			}

			let error = Errno(rawValue: errno)

			if error == .attributeNotFound {
				return false
			}

			throw error
		}
	}

	/**
	Removes the extended attribute specified by the given name.

	- Parameter name: The name of the attribute.
	- Throws: An error if the file is not accessible or the operation fails. It does not throw if the attribute does not exist.
	*/
	public func remove(_ name: String) throws {
		do {
			try _remove(name)
		} catch Errno.attributeNotFound {}
	}

	/**
	Retrieves all extended attribute names of the file.

	- Parameter withFlags: Specifies whether the names should include flags (e.g., `com.apple.metadata:kMDItemCreator#S`).
	- Returns: An array of attribute names.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func allNames(withFlags: Bool) throws -> [String] {
		try checkIfFileURL()

		let data: Data = try url.withUnsafeFileSystemRepresentation { fileSystemPath in
			let size = listxattr(fileSystemPath, nil, 0, 0)

			guard size >= 0 else {
				throw Errno(rawValue: errno)
			}

			var data = Data(count: size)

			let length = data.withUnsafeMutableBytes {
				listxattr(fileSystemPath, $0.baseAddress, size, 0)
			}

			guard length >= 0 else {
				throw Errno(rawValue: errno)
			}

			return data
		}

		var names = data.split(separator: 0).compactMap(\.toString)

		if !withFlags {
			names = try names.map { try Self.nameWithoutFlags($0) }
		}

		return names
	}

	private func checkIfFileURL() throws {
		guard url.isFileURL else {
			throw CocoaError(.fileNoSuchFile)
		}
	}

	private func _get(_ name: String) throws -> Data {
		try checkIfFileURL()

		return try url.withUnsafeFileSystemRepresentation { fileSystemPath in
			let size = getxattr(fileSystemPath, name, nil, 0, 0, 0)

			guard size >= 0 else {
				throw Errno(rawValue: errno)
			}

			var data = Data(count: size)

			let byteCount = data.withUnsafeMutableBytes {
				getxattr(fileSystemPath, name, $0.baseAddress, size, 0, 0)
			}

			guard byteCount >= 0 else {
				throw Errno(rawValue: errno)
			}

			return data
		}
	}

	private func _remove(_ name: String) throws {
		try checkIfFileURL()

		try url.withUnsafeFileSystemRepresentation { fileSystemPath in
			try Errno.wrap {
				removexattr(fileSystemPath, name, 0)
			}
		}
	}

	// TODO: Add subscript when Swift supports throwing setters.
	// `try url.extendedAttributes["foo"] = "bar".toData
}

extension ExtendedAttributes {
	// Docs: https://www.manpagez.com/man/3/xattr_flags_from_name/

	static func flagsFromName(_ name: String) -> Flags {
		Flags(rawValue: xattr_flags_from_name(name))
	}

	static func nameWithoutFlags(_ name: String) throws -> String {
		guard let newName = xattr_name_without_flags(name) else {
			throw Errno(rawValue: errno)
		}

		defer {
			newName.deallocate()
		}

		return String(cString: newName)
	}

	static func nameWithFlags(_ name: String, flags: Flags) throws -> String {
		guard let newName = xattr_name_with_flags(name, flags.rawValue) else {
			throw Errno(rawValue: errno)
		}

		defer {
			newName.deallocate()
		}

		return String(cString: newName)
	}
}

extension ExtendedAttributes {
	/**
	Retrieves the value of the extended attribute specified by the given name and deserializes its value into the specified type.

	- Parameter name: The name of the attribute.
	- Parameter type: The type to deserialize the attribute value into.
	- Returns: The attribute value or `nil` if it does not exist.
	- Note: The system usually stores extended attributes as property lists, but other extended attributes may be stored as strings.

	```swift
	let isProtected = try? attributes.getPropertyListSerializedValue("com.apple.rootless", type: Bool.self) ?? false
	```
	*/
	public func getPropertyListSerializedValue<T>(
		_ name: String,
		type: T.Type
	) throws -> T? {
		try checkIfFileURL()

		guard let data = try get(name) else {
			return nil
		}

		let value = try PropertyListSerialization.propertyList(from: data, options: [], format: nil)

		guard let result = value as? T else {
			throw CocoaError(.propertyListReadCorrupt)
		}

		return result
	}

	/**
	Sets the value of the extended attribute specified by the given name by serializing the given data into a property list.

	- Parameter name: The name of the attribute.
	- Parameter value: The value to serialize into a property list.
	- Parameter flags: Optional flags to apply when setting the attribute.

	```swift
	try attributes.setPropertyListSerializedValue("com.apple.rootless", value: true)
	```
	*/
	public func setPropertyListSerializedValue(
		_ name: String,
		value: some Any,
		flags: Flags? = nil
	) throws {
		try checkIfFileURL()

		guard PropertyListSerialization.propertyList(value, isValidFor: .binary) else {
			throw CocoaError(.propertyListWriteInvalid)
		}

		let data = try PropertyListSerialization.data(fromPropertyList: value, format: .binary, options: 0)
		try set(name, data: data, flags: flags)
	}
}

extension URL {
	/**
	Provides convenient access to the extended attributes of the file/folder at the URL.

	See ``ExtendedAttributes`` for the API documentation.
	*/
	public var extendedAttributes: ExtendedAttributes { .init(url: self) }
}
