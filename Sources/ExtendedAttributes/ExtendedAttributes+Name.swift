extension ExtendedAttributes {
	/**
	A strongly-typed extended attribute name that knows how to encode and decode its value.

	Use this to create custom strongly-typed attribute names:

	```swift
	let customName = ExtendedAttributes.Name<String>(
		name: "com.example.custom",
		get: { api in
			guard let data = try api.get("com.example.custom") else {
				return nil
			}

			return String(data: data, encoding: .utf8)
		},
		set: { api, value, flags in
			let data = Data(value.utf8)
			try api.set("com.example.custom", data: data, flags: flags)
		}
	)

	let fileURL = URL(filePath: "/path/to/file")
	try fileURL.extendedAttributes.set(customName, value: "Custom Value")
	let value = try fileURL.extendedAttributes.get(customName)
	```

	Or define reusable names as static properties:

	```swift
	extension ExtendedAttributes.Name {
		static let myCustomAttribute = ExtendedAttributes.Name.string(
			name: "com.mycompany.customAttribute"
		)
	}

	// Usage:
	try fileURL.extendedAttributes.set(.myCustomAttribute, value: "Hello")
	let value = try fileURL.extendedAttributes.get(.myCustomAttribute)
	```
	*/
	public struct Name<T>: Sendable {
		public typealias Value = T

		public let rawName: String
		private let getter: @Sendable (ExtendedAttributes) throws -> T?
		private let setter: @Sendable (ExtendedAttributes, T, ExtendedAttributes.Flags?) throws -> Void

		/**
		Creates a strongly-typed extended attribute name.

		- Parameters:
			- name: The raw extended attribute name.
			- get: A closure that retrieves the typed value from the extended attributes API.
			- set: A closure that sets the typed value using the extended attributes API.
		*/
		public init(
			name: String,
			get: @escaping @Sendable (ExtendedAttributes) throws -> T?,
			set: @escaping @Sendable (ExtendedAttributes, T, ExtendedAttributes.Flags?) throws -> Void
		) {
			self.rawName = name
			self.getter = get
			self.setter = set
		}

		internal func get(from api: ExtendedAttributes) throws -> T? {
			try getter(api)
		}

		internal func set(
			_ value: T,
			to api: ExtendedAttributes,
			flags: ExtendedAttributes.Flags? = nil
		) throws {
			try setter(api, value, flags)
		}

		internal func has(in api: ExtendedAttributes) throws -> Bool {
			try api.has(rawName)
		}

		internal func remove(from api: ExtendedAttributes) throws {
			try api.remove(rawName)
		}
	}
}
