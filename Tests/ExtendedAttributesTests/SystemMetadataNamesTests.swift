import Foundation
import Testing
import ExtendedAttributes

@Suite("System Metadata Names")
struct SystemMetadataNamesTests {
	@Test("Common system metadata attributes")
	func commonSystemMetadataAttributes() throws {
		try TestHelpers.withTestFile { fileURL in
			// Test setting and getting system metadata
			try fileURL.systemMetadata.set(.creator, value: "TestApp")
			let creator = try fileURL.systemMetadata.get(.creator)
			#expect(creator == "TestApp")

			try fileURL.systemMetadata.set(.keywords, value: ["test", "swift"])
			let keywords = try fileURL.systemMetadata.get(.keywords)
			#expect(keywords == ["test", "swift"])

			try fileURL.systemMetadata.set(.starRating, value: 4)
			let rating = try fileURL.systemMetadata.get(.starRating)
			#expect(rating == 4)
		}
	}

	@Test("URL conversion for whereFroms")
	func whereFromsURLConversion() throws {
		try TestHelpers.withTestFile { fileURL in
			let testURLs = [
				URL(string: "https://example.com/file.zip")!,
				URL(string: "https://github.com/user/repo")!
			]

			try fileURL.systemMetadata.set(.whereFroms, value: testURLs)
			let retrievedURLs = try fileURL.systemMetadata.get(.whereFroms)

			#expect(retrievedURLs == testURLs)
		}
	}
}
