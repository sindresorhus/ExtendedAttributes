extension SystemMetadata {
	/**
	A strongly-typed system metadata name that knows how to encode and decode its value.

	You can create custom strongly-typed metadata names:

	```swift
	extension SystemMetadata.Name {
		static let myCustomMetadata = SystemMetadata.Name(
			"kMDItemMyCustomData",
			type: String.self
		)
	}

	// Usage:
	let fileURL = URL(filePath: "/path/to/file")
	try fileURL.systemMetadata.set(.myCustomMetadata, value: "Custom Value")
	let value = try fileURL.systemMetadata.get(.myCustomMetadata)
	```
	*/
	public struct Name<T>: Sendable {
		public typealias Value = T

		public let rawName: String
		private let getter: @Sendable (SystemMetadata) throws -> T?
		private let setter: @Sendable (SystemMetadata, T) throws -> Void

		/**
		Creates a strongly-typed system metadata name.

		- Parameters:
			- name: The metadata key name (without the com.apple.metadata: prefix).
			- type: The type of the metadata value.
		*/
		public init(_ name: String, type: T.Type) {
			self.rawName = name
			self.getter = { metadata in
				try metadata.get(name, type: type)
			}
			self.setter = { metadata, value in
				try metadata.set(name, value: value)
			}
		}

		/**
		Creates a strongly-typed system metadata name with custom getter and setter.

		- Parameters:
			- name: The metadata key name (without the com.apple.metadata: prefix).
			- type: The type of the metadata value.
			- get: Custom getter implementation.
			- set: Custom setter implementation.
		*/
		public init(
			_ name: String,
			type: T.Type,
			get: @escaping @Sendable (SystemMetadata) throws -> T?,
			set: @escaping @Sendable (SystemMetadata, T) throws -> Void
		) {
			self.rawName = name
			self.getter = get
			self.setter = set
		}

		internal func get(from metadata: SystemMetadata) throws -> T? {
			try getter(metadata)
		}

		internal func set(_ value: T, to metadata: SystemMetadata) throws {
			try setter(metadata, value)
		}

		internal func has(in metadata: SystemMetadata) throws -> Bool {
			try metadata.has(rawName)
		}

		internal func remove(from metadata: SystemMetadata) throws {
			try metadata.remove(rawName)
		}
	}
}
