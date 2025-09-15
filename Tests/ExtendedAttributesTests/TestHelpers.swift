import Foundation

enum TestHelpers {
	static func createTestFile() -> URL {
		let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
		try! Data("Test content".utf8).write(to: url)
		return url
	}

	static func createTestDirectory() -> URL {
		let url = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString, isDirectory: true)
		try! FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
		return url
	}

	static func cleanup(_ url: URL) {
		try? FileManager.default.removeItem(at: url)
	}

	@discardableResult
	static func withTestFile<T>(_ test: (URL) throws -> T) throws -> T {
		let fileURL = createTestFile()
		defer {
			cleanup(fileURL)
		}

		return try test(fileURL)
	}

	@discardableResult
	static func withTestDirectory<T>(_ test: (URL) throws -> T) throws -> T {
		let directoryURL = createTestDirectory()
		defer {
			cleanup(directoryURL)
		}

		return try test(directoryURL)
	}
}
