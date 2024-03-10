import Foundation
import XCTest
import ExtendedAttributes

final class ExtendedAttributesTests: XCTestCase {
	private var testFileURL: URL!

	override func setUp() {
		super.setUp()
		let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try? Data("Test".utf8).write(to: temporaryFileURL)
		testFileURL = temporaryFileURL
	}

	override func tearDown() {
		try? FileManager.default.removeItem(at: testFileURL)
		testFileURL = nil
		super.tearDown()
	}

	func testGet() throws {
		let attributeName = "testAttribute"
		let attributeValue = "Test Value".toData
		try testFileURL.extendedAttributes.set(attributeName, data: attributeValue)

		let fetchedValue = try testFileURL.extendedAttributes.get(attributeName)
		XCTAssertEqual(fetchedValue, attributeValue, "Fetched attribute value should match the set value.")
	}

	func testSet() throws {
		let attributeName = "testAttributeSet"
		let attributeValue = "Another Test Value".toData
		try testFileURL.extendedAttributes.set(attributeName, data: attributeValue)

		let fetchedValue = try testFileURL.extendedAttributes.get(attributeName)
		XCTAssertEqual(fetchedValue, attributeValue, "Set attribute value should be retrievable.")
	}

	func testHas() throws {
		let attributeName = "testAttributeHas"
		try testFileURL.extendedAttributes.set(attributeName, data: Data())

		let exists = try testFileURL.extendedAttributes.has(attributeName)
		XCTAssertTrue(exists, "Attribute should exist after being set.")
	}

	func testRemove() throws {
		let attributeName = "testAttributeRemove"
		try testFileURL.extendedAttributes.set(attributeName, data: Data())
		try testFileURL.extendedAttributes.remove(attributeName)

		let exists = try testFileURL.extendedAttributes.has(attributeName)
		XCTAssertFalse(exists, "Attribute should not exist after being removed.")
	}

	func testAllNames() throws {
		let attributeName1 = "testAttribute1"
		let attributeName2 = "testAttribute2"
		try testFileURL.extendedAttributes.set(attributeName1, data: Data())
		try testFileURL.extendedAttributes.set(attributeName2, data: Data())

		let names = try testFileURL.extendedAttributes.allNames(withFlags: false)
		XCTAssertTrue(names.contains(attributeName1) && names.contains(attributeName2), "All names should include set attributes.")
	}

	func testGetPropertyListSerializedValue() throws {
		let attributeName = "testPropertyList"
		let attributeValue = ["Key": "Value"]
		try testFileURL.extendedAttributes.setPropertyListSerializedValue(attributeName, value: attributeValue)

		let fetchedValue = try testFileURL.extendedAttributes.getPropertyListSerializedValue(attributeName, type: [String: String].self)
		XCTAssertEqual(fetchedValue, attributeValue, "Fetched property list should match the set value.")
	}

	func testSetPropertyListSerializedValue() throws {
		let attributeName = "testPropertyListSet"
		let attributeValue = ["AnotherKey": "AnotherValue"]
		try testFileURL.extendedAttributes.setPropertyListSerializedValue(attributeName, value: attributeValue)

		let fetchedValue = try testFileURL.extendedAttributes.getPropertyListSerializedValue(attributeName, type: [String: String].self)
		XCTAssertEqual(fetchedValue, attributeValue, "Set property list should be retrievable.")
	}
}

final class SystemMetadataTests: XCTestCase {
	private var testFileURL: URL!

	override func setUp() {
		super.setUp()
		let temporaryFileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try? Data("Test".utf8).write(to: temporaryFileURL)
		testFileURL = temporaryFileURL
	}

	override func tearDown() {
		try? FileManager.default.removeItem(at: testFileURL)
		testFileURL = nil
		super.tearDown()
	}

	func testMetadata() throws {
		let key = "kMDItemDescription"
		let value = "Test Description"
		try testFileURL.systemMetadata.set(key, value: value)

		let fetchedValue: String? = try testFileURL.systemMetadata.get(key, type: String.self)
		XCTAssertEqual(fetchedValue, value, "The fetched value should match the set value.")
	}
}

extension String {
	var toData: Data { Data(utf8) }
}
