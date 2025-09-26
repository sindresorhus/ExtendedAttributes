import Foundation
import Testing
import ExtendedAttributes

// swiftlint:disable discouraged_optional_collection non_optional_string_data_conversion

@Suite("ExtendedAttributes")
struct ExtendedAttributesTests {
	@Test("Basic get/set operations")
	func basicOperations() throws {
		try TestHelpers.withTestFile { fileURL in
		let attributeName = "com.example.test"
		let attributeValue = "Test Value".data(using: .utf8)!

		try fileURL.extendedAttributes.set(attributeName, data: attributeValue)

			let fetchedValue = try fileURL.extendedAttributes.get(attributeName)
			#expect(fetchedValue == attributeValue)
		}
	}

	@Test("Get non-existent attribute returns nil")
	func getNonExistentAttribute() throws {
		try TestHelpers.withTestFile { fileURL in
			let value = try fileURL.extendedAttributes.get("non.existent.attribute")
			#expect(value == nil)
		}
	}

	@Test("Has attribute detection")
	func hasAttribute() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.exists"

			#expect(try !fileURL.extendedAttributes.has(attributeName))

			try fileURL.extendedAttributes.set(attributeName, data: Data())
			#expect(try fileURL.extendedAttributes.has(attributeName))
		}
	}

	@Test("Remove attribute")
	func removeAttribute() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.removable"
			let data = "To be removed".data(using: .utf8)!

			try fileURL.extendedAttributes.set(attributeName, data: data)
			#expect(try fileURL.extendedAttributes.has(attributeName))

			try fileURL.extendedAttributes.remove(attributeName)
			#expect(try !fileURL.extendedAttributes.has(attributeName))
		}
	}

	@Test("Remove non-existent attribute doesn't throw")
	func removeNonExistentAttribute() throws {
		try TestHelpers.withTestFile { fileURL in
			#expect(throws: Never.self) {
				try fileURL.extendedAttributes.remove("non.existent")
			}
		}
	}

	@Test("Get all attribute names")
	func allNames() throws {
		try TestHelpers.withTestFile { fileURL in
			try fileURL.extendedAttributes.set("com.example.test", data: Data("test".utf8))

			let names = try fileURL.extendedAttributes.allNames()
			#expect(names.contains("com.example.test"))
		}
	}


	@Test("Empty data handling")
	func emptyData() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.empty"
			let emptyData = Data()

			try fileURL.extendedAttributes.set(attributeName, data: emptyData)
			let retrieved = try fileURL.extendedAttributes.get(attributeName)
			#expect(retrieved == emptyData)
			#expect(retrieved?.isEmpty == true)
		}
	}

	@Test("Works with directories")
	func directorySupport() throws {
		try TestHelpers.withTestDirectory { dirURL in
			let attributeName = "com.example.dir"
			let data = "Directory attribute".data(using: .utf8)!

			try dirURL.extendedAttributes.set(attributeName, data: data)
			#expect(try dirURL.extendedAttributes.get(attributeName) == data)
		}
	}

	@Test("Binary data handling")
	func binaryData() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.binary"
			let binaryData = Data([0x00, 0x01, 0x02, 0xFF, 0xFE, 0xFD])

			try fileURL.extendedAttributes.set(attributeName, data: binaryData)
			let retrieved = try fileURL.extendedAttributes.get(attributeName)
			#expect(retrieved == binaryData)
		}
	}

	@Test("Update existing attribute")
	func updateExistingAttribute() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.updatable"
			let originalData = "Original".data(using: .utf8)!
			let updatedData = "Updated".data(using: .utf8)!

			try fileURL.extendedAttributes.set(attributeName, data: originalData)
			#expect(try fileURL.extendedAttributes.get(attributeName) == originalData)

			try fileURL.extendedAttributes.set(attributeName, data: updatedData)
			#expect(try fileURL.extendedAttributes.get(attributeName) == updatedData)
		}
	}

	@Test("Invalid URL throws error")
	func invalidURL() throws {
		let invalidURL = URL(string: "https://example.com")!

		#expect(throws: CocoaError.self) {
			try invalidURL.extendedAttributes.set("test", data: Data())
		}

		#expect(throws: CocoaError.self) {
			_ = try invalidURL.extendedAttributes.get("test")
		}
	}

	@Test("Non-existent file throws error")
	func nonExistentFile() throws {
		let nonExistentURL = URL(fileURLWithPath: "/non/existent/file.txt")

		#expect(throws: Error.self) {
			try nonExistentURL.extendedAttributes.set("test", data: Data())
		}
	}

	@Test("Property list serialization")
	func propertyListSerialization() throws {
		try TestHelpers.withTestFile { fileURL in
			// Test dictionary
			let dictionary = ["key": "value", "number": "42"]
			try fileURL.extendedAttributes.setPropertyListSerializedValue("dict", value: dictionary)
			let retrievedDict: [String: String]? = try fileURL.extendedAttributes.getPropertyListSerializedValue("dict", type: [String: String].self)
			#expect(retrievedDict == dictionary)

			// Test array
			let array = ["one", "two", "three"]
			try fileURL.extendedAttributes.setPropertyListSerializedValue("array", value: array)
			let retrievedArray: [String]? = try fileURL.extendedAttributes.getPropertyListSerializedValue("array", type: [String].self)
			#expect(retrievedArray == array)
		}
	}
}

@Suite("ExtendedAttributes Flags")
struct ExtendedAttributesFlagsTests {
	@Test("Set attribute with noExport flag")
	func noExportFlag() throws {
		try TestHelpers.withTestFile { fileURL in
		let attributeName = "com.example.noexport"
		let data = "No export".data(using: .utf8)!

		try fileURL.extendedAttributes.set(attributeName, data: data, flags: .noExport)

		// Verify flag is applied by checking names with flags
		let allNamesWithFlags = try fileURL.extendedAttributes.allNames(withFlags: true)
			let nameWithFlag = allNamesWithFlags.first { $0.contains(attributeName) }
			#expect(nameWithFlag?.contains("#") == true)
		}
	}

	@Test("Set attribute with contentDependent flag")
	func contentDependentFlag() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.contentdep"
			let data = "Content dependent".data(using: .utf8)!

			try fileURL.extendedAttributes.set(attributeName, data: data, flags: .contentDependent)

			// Verify flag is applied
			let allNamesWithFlags = try fileURL.extendedAttributes.allNames(withFlags: true)
			let nameWithFlag = allNamesWithFlags.first { $0.contains(attributeName) }
			#expect(nameWithFlag != nil)
		}
	}

	@Test("Set attribute with multiple flags")
	func multipleFlags() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.multiflags"
			let data = "Multiple flags".data(using: .utf8)!

			let flags: ExtendedAttributes.Flags = [.noExport, .syncable]
			try fileURL.extendedAttributes.set(attributeName, data: data, flags: flags)

			// Verify flags are applied
			let allNamesWithFlags = try fileURL.extendedAttributes.allNames(withFlags: true)
			let nameWithFlag = allNamesWithFlags.first { $0.contains(attributeName) }
			#expect(nameWithFlag != nil)
		}
	}

	@Test("Get names with and without flags")
	func namesWithAndWithoutFlags() throws {
		try TestHelpers.withTestFile { fileURL in
			let attributeName = "com.example.flagtest"
			let data = "Flag test".data(using: .utf8)!

			try fileURL.extendedAttributes.set(attributeName, data: data, flags: .noExport)

			let namesWithFlags = try fileURL.extendedAttributes.allNames(withFlags: true)
			let namesWithoutFlags = try fileURL.extendedAttributes.allNames(withFlags: false)

			let withFlag = namesWithFlags.first { $0.contains(attributeName) }
			let withoutFlag = namesWithoutFlags.first { $0.contains(attributeName) }

			#expect(withFlag?.contains("#") == true)
			#expect(withoutFlag == attributeName)
		}
	}
}

@Suite("SystemMetadata")
struct SystemMetadataTests {
	@Test("Set and get metadata")
	func setGetMetadata() throws {
		try TestHelpers.withTestFile { fileURL in
		let key = "kMDItemDescription"
		let value = "Test Description"

		try fileURL.systemMetadata.set(key, value: value)
		let retrieved = try fileURL.systemMetadata.get(key, type: String.self)

			#expect(retrieved == value)
		}
	}

	@Test("Has metadata")
	func hasMetadata() throws {
		try TestHelpers.withTestFile { fileURL in
			let key = "kMDItemKeywords"

			#expect(try !fileURL.systemMetadata.has(key))

			try fileURL.systemMetadata.set(key, value: ["test", "keywords"])
			#expect(try fileURL.systemMetadata.has(key))
		}
	}

	@Test("Remove metadata")
	func removeMetadata() throws {
		try TestHelpers.withTestFile { fileURL in
			let key = "kMDItemComment"
			let value = "To be removed"

			try fileURL.systemMetadata.set(key, value: value)
			#expect(try fileURL.systemMetadata.has(key))

			try fileURL.systemMetadata.remove(key)
			#expect(try !fileURL.systemMetadata.has(key))
		}
	}

	@Test("Get non-existent metadata returns nil")
	func nonExistentMetadata() throws {
		try TestHelpers.withTestFile { fileURL in
			let value = try fileURL.systemMetadata.get("kMDItemNonExistent", type: String.self)
			#expect(value == nil)
		}
	}

	@Test("Metadata uses correct namespace")
	func metadataNamespace() throws {
		try TestHelpers.withTestFile { fileURL in
			let key = "TestKey"
			let value = "TestValue"

			try fileURL.systemMetadata.set(key, value: value)

			let allNames = try fileURL.extendedAttributes.allNames(withFlags: false)
			let expectedName = "com.apple.metadata:TestKey"
			#expect(allNames.contains(expectedName))
		}
	}
}

// swiftlint:enable discouraged_optional_collection non_optional_string_data_conversion
