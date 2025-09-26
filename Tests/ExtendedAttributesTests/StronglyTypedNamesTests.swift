import Foundation
import Testing
import ExtendedAttributes

@Suite("Strongly-Typed Extended Attribute Names")
struct StronglyTypedNamesTests {
	@Test("Custom strongly-typed name creation")
	func customNameCreation() throws {
		try TestHelpers.withTestFile { fileURL in
			let customName = ExtendedAttributes.Name<String>(
				name: "com.example.custom",
				get: { api in
					guard let data = try api.get("com.example.custom") else {
						return nil
					}

					return String(data: data, encoding: .utf8)
				},
				set: { api, value, flags in
					try api.set("com.example.custom", data: Data(value.utf8), flags: flags)
				}
			)

			try fileURL.extendedAttributes.set(customName, value: "Custom Value")
			#expect(try fileURL.extendedAttributes.get(customName) == "Custom Value")
			#expect(try fileURL.extendedAttributes.has(customName))

			try fileURL.extendedAttributes.remove(customName)
			#expect(try !fileURL.extendedAttributes.has(customName))
		}
	}

	@Test("Common predefined attributes")
	func commonPredefinedAttributes() throws {
		try TestHelpers.withTestFile { fileURL in
			// Test string attributes
			try fileURL.extendedAttributes.set(.quarantine, value: "test-quarantine")
			#expect(try fileURL.extendedAttributes.get(.quarantine) == .some("test-quarantine"))

			// Test boolean attributes with defaults
			#expect(try fileURL.extendedAttributes.get(.isProtected) == false)

			// Test system metadata attributes (these should be accessed via systemMetadata)
			try fileURL.systemMetadata.set(.keywords, value: ["swift", "testing"])
			#expect(try fileURL.systemMetadata.get(.keywords) == ["swift", "testing"])

			try fileURL.systemMetadata.set(.starRating, value: 5)
			#expect(try fileURL.systemMetadata.get(.starRating) == 5)
		}
	}

	@Test("Factory methods")
	func factoryMethods() throws {
		try TestHelpers.withTestFile { fileURL in
			// String factory
			let stringName: ExtendedAttributes.Name<String?> = .string(name: "com.example.text")
			try fileURL.extendedAttributes.set(stringName, value: "Hello, World!")
			#expect(try fileURL.extendedAttributes.get(stringName) == "Hello, World!")

			// Data factory
			let dataName: ExtendedAttributes.Name<Data?> = .data(name: "com.example.binary")
			let testData = Data([0xFF, 0xFE, 0xFD])
			try fileURL.extendedAttributes.set(dataName, value: testData)
			#expect(try fileURL.extendedAttributes.get(dataName) == testData)

			// Property list factory
			let dictName: ExtendedAttributes.Name<[String: String]?> = .propertyList(name: "com.example.dict", type: [String: String].self) // swiftlint:disable:this discouraged_optional_collection
			try fileURL.extendedAttributes.set(dictName, value: ["key": "value"])
			#expect(try fileURL.extendedAttributes.get(dictName) == ["key": "value"])
		}
	}

	@Test("Nil handling in factory methods")
	func nilHandlingInFactoryMethods() throws {
		try TestHelpers.withTestFile { fileURL in
			let stringName: ExtendedAttributes.Name<String?> = .string(name: "com.example.removable")
			try fileURL.extendedAttributes.set(stringName, value: "test")
			#expect(try fileURL.extendedAttributes.has(stringName))

			// Setting nil should remove the attribute
			try fileURL.extendedAttributes.set(stringName, value: nil)
			#expect(try !fileURL.extendedAttributes.has(stringName))
		}
	}

	@Test("Error handling")
	func errorHandling() throws {
		let invalidURL = URL(string: "https://example.com")!
		let testName: ExtendedAttributes.Name<String?> = .string(name: "test")

		#expect(throws: Error.self) {
			try invalidURL.extendedAttributes.set(testName, value: "test")
		}

		#expect(throws: Error.self) {
			_ = try invalidURL.extendedAttributes.get(testName)
		}
	}

	@Test("Strongly-typed names with flags")
	func stronglyTypedNamesWithFlags() throws {
		try TestHelpers.withTestFile { fileURL in
			let testName: ExtendedAttributes.Name<String?> = .string(name: "com.example.flagged")
			try fileURL.extendedAttributes.set(testName, value: "flagged", flags: .noExport)

			let allNamesWithFlags = try fileURL.extendedAttributes.allNames(withFlags: true)
			let nameWithFlag = allNamesWithFlags.first { $0.contains("com.example.flagged") }
			#expect(nameWithFlag?.contains("#") == true)
		}
	}

	@Test("Multiple attributes with direct syntax")
	func multipleAttributesWithDirectSyntax() throws {
		try TestHelpers.withTestFile { fileURL in
			// Set extended attributes (note: isProtected is read-only, so we just test reading)
			try fileURL.extendedAttributes.set(.quarantine, value: "test-quarantine")

			// Set system metadata attributes
			try fileURL.systemMetadata.set(.keywords, value: ["swift", "test"])
			try fileURL.systemMetadata.set(.starRating, value: 5)

			// Verify extended attributes
			#expect(try fileURL.extendedAttributes.get(.isProtected) == false) // Default value
			#expect(try fileURL.extendedAttributes.get(.quarantine) == "test-quarantine")

			// Verify system metadata
			#expect(try fileURL.systemMetadata.get(.keywords) == ["swift", "test"])
			#expect(try fileURL.systemMetadata.get(.starRating) == 5)

			// Verify existence checks work
			#expect(try fileURL.extendedAttributes.has(.quarantine))
			#expect(try fileURL.systemMetadata.has(.keywords))
			#expect(try fileURL.systemMetadata.has(.starRating))
		}
	}

	@Test("Default values work correctly")
	func defaultValues() throws {
		try TestHelpers.withTestFile { fileURL in
			// Extended attribute with default value
			#expect(try fileURL.extendedAttributes.get(.isProtected) == false)

			// System metadata attributes return nil when not set (no default values)
			let keywords = try fileURL.systemMetadata.get(.keywords)
			let starRating = try fileURL.systemMetadata.get(.starRating)
			#expect(keywords == nil, "Keywords should be nil")
			#expect(starRating == nil, "Star rating should be nil")
		}
	}

	@Test("Works with directories")
	func worksWithDirectories() throws {
		try TestHelpers.withTestDirectory { directoryURL in
			try directoryURL.systemMetadata.set(.keywords, value: ["directory", "test"])
			#expect(try directoryURL.systemMetadata.get(.keywords) == ["directory", "test"])
		}
	}
}
