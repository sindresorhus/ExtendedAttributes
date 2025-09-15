import Foundation

extension ExtendedAttributes {
	/**
	Get the value of a strongly-typed extended attribute.

	- Parameter name: The strongly-typed attribute name.
	- Returns: The typed value or `nil` if it does not exist.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func get<T>(_ name: Name<T>) throws -> T? {
		try name.get(from: self)
	}

	/**
	Set the value of a strongly-typed extended attribute.

	- Parameters:
		- name: The strongly-typed attribute name.
		- value: The typed value to set.
		- flags: Optional flags to specify behavior of the attribute setting.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func set<T>(_ name: Name<T>, value: T, flags: Flags? = nil) throws {
		try name.set(value, to: self, flags: flags)
	}

	/**
	Check if a strongly-typed extended attribute exists.

	- Parameter name: The strongly-typed attribute name.
	- Returns: `true` if the attribute exists, otherwise `false`.
	- Throws: An error if the file is not accessible or the operation fails.
	*/
	public func has<T>(_ name: Name<T>) throws -> Bool {
		try name.has(in: self)
	}

	/**
	Remove a strongly-typed extended attribute.

	- Parameter name: The strongly-typed attribute name.
	- Throws: An error if the file is not accessible or the operation fails. It does not throw if the attribute does not exist.
	*/
	public func remove<T>(_ name: Name<T>) throws {
		try name.remove(from: self)
	}
}

// MARK: - Name Factory Methods

extension ExtendedAttributes.Name {
	/**
	Creates a name for property list attributes with an optional default value.
	*/
	public static func propertyList<U: Sendable>(
		name: String,
		type: U.Type,
		defaultValue: U
	) -> ExtendedAttributes.Name<U> {
		.init(
			name: name,
			get: { api in
				try api.getPropertyListSerializedValue(name, type: type) ?? defaultValue
			},
			set: { api, value, flags in
				try api.setPropertyListSerializedValue(name, value: value, flags: flags)
			}
		)
	}

	/**
	Creates a name for optional property list attributes.
	*/
	public static func propertyList<U>(
		name: String,
		type: U.Type
	) -> ExtendedAttributes.Name<U?> {
		.init(
			name: name,
			get: { api in
				try api.getPropertyListSerializedValue(name, type: type)
			},
			set: { api, value, flags in
				guard let value else {
					try api.remove(name)
					return
				}

				try api.setPropertyListSerializedValue(name, value: value, flags: flags)
			}
		)
	}

	/**
	Creates a name for string attributes stored as UTF-8 data.
	*/
	public static func string(name: String) -> ExtendedAttributes.Name<String?> {
		.init(
			name: name,
			get: { api in
				guard let data = try api.get(name) else {
					return nil
				}

				return String(data: data, encoding: .utf8)
			},
			set: { api, value, flags in
				guard let value else {
					try api.remove(name)
					return
				}
				try api.set(name, data: Data(value.utf8), flags: flags)
			}
		)
	}

	/**
	Creates a name for raw data attributes.
	*/
	public static func data(name: String) -> ExtendedAttributes.Name<Data?> {
		.init(
			name: name,
			get: {
				api in try api.get(name)
			},
			set: { api, value, flags in
				guard let value else {
					try api.remove(name)
					return
				}

				try api.set(name, data: value, flags: flags)
			}
		)
	}
}

extension ExtendedAttributes.Name {
	// MARK: - Security and Protection

	/**
	Indicates whether the file is protected by System Integrity Protection (SIP).

	This attribute is typically found on system files and indicates they cannot be modified even by root.

	- Note: This attribute is typically read-only. Attempting to set it may result in an "Operation not permitted" error.
	*/
	public static var isProtected: ExtendedAttributes.Name<Bool> {
		.propertyList(
			name: "com.apple.rootless",
			type: Bool.self,
			defaultValue: false
		)
	}

	/**
	Quarantine information for downloaded files.

	Contains information about where the file was downloaded from and when.
	*/
	public static var quarantine: ExtendedAttributes.Name<String?> {
		.string(name: "com.apple.quarantine")
	}

	// MARK: - Finder Information

	/**
	The last date this file was used.

	This attribute tracks when the file was last opened or accessed.
	*/
	public static var lastUsedDate: ExtendedAttributes.Name<Data?> {
		.data(name: "com.apple.lastuseddate#PS")
	}

	/**
	Finder information for the file.

	Contains various Finder-specific metadata about the file including type/creator codes, flags, and position information.
	*/
	public static var finderInfo: ExtendedAttributes.Name<Data?> {
		.data(name: "com.apple.FinderInfo")
	}

	/**
	Resource fork of the file.

	Contains the resource fork data for files that have one.
	*/
	public static var resourceFork: ExtendedAttributes.Name<Data?> {
		.data(name: "com.apple.ResourceFork")
	}

	// MARK: - Text Encoding

	/**
	Text encoding of the file.

	Stores the text encoding used by the file (e.g., UTF-8, UTF-16).
	*/
	public static var textEncoding: ExtendedAttributes.Name<String?> {
		.string(name: "com.apple.TextEncoding")
	}
}
