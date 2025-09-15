import Foundation

extension SystemMetadata.Name {
	// MARK: - Creator Information

	/**
	App used to create the document content (for example "Word", "Pages", and so on).
	*/
	public static var creator: SystemMetadata.Name<String> {
		.init(kMDItemCreator as String, type: String.self)
	}

	/**
	Name of the person or organization that created the document.
	*/
	public static var authors: SystemMetadata.Name<[String]> {
		.init(kMDItemAuthors as String, type: [String].self)
	}

	/**
	Copyright notice of the document.
	*/
	public static var copyright: SystemMetadata.Name<String> {
		.init(kMDItemCopyright as String, type: String.self)
	}

	// MARK: - File Information

	/**
	File name, including extension.
	*/
	public static var displayName: SystemMetadata.Name<String> {
		.init(kMDItemDisplayName as String, type: String.self)
	}

	/**
	Description or abstract of the document.
	*/
	public static var description: SystemMetadata.Name<String> {
		.init(kMDItemDescription as String, type: String.self)
	}

	/**
	Keywords associated with the file.
	*/
	public static var keywords: SystemMetadata.Name<[String]> {
		.init(kMDItemKeywords as String, type: [String].self)
	}

	/**
	Subject of the document.
	*/
	public static var subject: SystemMetadata.Name<String> {
		.init(kMDItemSubject as String, type: String.self)
	}

	/**
	Title of the document.
	*/
	public static var title: SystemMetadata.Name<String> {
		.init(kMDItemTitle as String, type: String.self)
	}

	// MARK: - Download Information

	/**
	URLs where this file was downloaded from.
	*/
	public static var whereFroms: SystemMetadata.Name<[URL]> {
		.init(
			kMDItemWhereFroms as String,
			type: [URL].self,
			get: { metadata in
				guard
					let strings = try metadata.get(kMDItemWhereFroms as String, type: [String].self)
				else {
					return nil
				}

				return strings.compactMap {
					if #available(macOS 14.0, *) {
						URL(string: $0, encodingInvalidCharacters: false)
					} else {
						URL(string: $0)
					}
				}
			},
			set: { metadata, urls in
				try metadata.set(
					kMDItemWhereFroms as String,
					value: urls.map(\.absoluteString)
				)
			}
		)
	}

	/**
	Date when this file was downloaded.
	*/
	public static var downloadedDate: SystemMetadata.Name<Date> {
		.init(
			kMDItemDownloadedDate as String,
			type: Date.self,
			get: { metadata in
				try metadata.get(kMDItemDownloadedDate as String, type: [Date].self)?.first
			},
			set: { metadata, value in
				// Store as array with single element as Apple expects
				try metadata.set(kMDItemDownloadedDate as String, value: [value])
			}
		)
	}

	// MARK: - Media Information

	/**
	Star rating of the file (0-5).
	*/
	public static var starRating: SystemMetadata.Name<Int> {
		.init(kMDItemStarRating as String, type: Int.self)
	}

	/**
	Indicates whether the file is a screenshot.
	*/
	public static var isScreenCapture: SystemMetadata.Name<Bool> {
		.init("kMDItemIsScreenCapture", type: Bool.self)
	}

	// MARK: - Content Information

	/**
	Text content of the document.
	*/
	public static var textContent: SystemMetadata.Name<String> {
		.init(kMDItemTextContent as String, type: String.self)
	}

	/**
	Instructions for using the document.
	*/
	public static var instructions: SystemMetadata.Name<String> {
		.init(kMDItemInstructions as String, type: String.self)
	}

	/**
	Comment on the file, as set by Finder.
	*/
	public static var finderComment: SystemMetadata.Name<String> {
		.init(kMDItemFinderComment as String, type: String.self)
	}

	// MARK: - Date Information

	/**
	Date the item was last used.
	*/
	public static var lastUsedDate: SystemMetadata.Name<Date> {
		.init(kMDItemLastUsedDate as String, type: Date.self)
	}
}
