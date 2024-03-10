import Foundation
import System

extension System.Errno {
	static func wrap(_ action: () -> Int32) throws {
		guard action() == 0 else {
			throw Self(rawValue: errno)
		}
	}
}

extension Data {
	var toString: String? { String(data: self, encoding: .utf8) }
}
