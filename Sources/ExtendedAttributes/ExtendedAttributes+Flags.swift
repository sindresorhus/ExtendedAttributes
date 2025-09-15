import Darwin

extension ExtendedAttributes {
	public struct Flags: OptionSet, Sendable {
		/**
		Declare that the attribute should not be exported. This is deliberately a bit vague, but this is used by `XATTR_OPERATION_INTENT_SHARE` to indicate not to preserve the attribute.
		*/
		public static let noExport = Self(rawValue: XATTR_FLAG_NO_EXPORT)

		/**
		Declares the  attribute to be tied to the contents of the file (or vice versa), such that it should be re-created when the contents of the file change. Examples might include cryptographic keys, checksums, saved position or search information, and text encoding.

		This property causes the attribute to be preserved for copy and share, but not for safe save. In a safe save, the attribute exists on the original, and will not be copied to the new version.
		*/
		public static let contentDependent = Self(rawValue: XATTR_FLAG_CONTENT_DEPENDENT)

		/**
		Declares that the attribute is never to be copied, for any intention type.
		*/
		public static let neverPreserve = Self(rawValue: XATTR_FLAG_NEVER_PRESERVE)

		/**
		Declares that the attribute is to be synced, used by the `XATTR_OPERATION_INTENT_SYNC` intention. Syncing tends to want to minimize the amount of metadata synced around, hence the default behavior is for the attribute NOT to be synced, even if it would else be preserved for the `XATTR_OPERATION_INTENT_COPY` intention.
		*/
		public static let syncable = Self(rawValue: XATTR_FLAG_SYNCABLE)

		/**
		Declares that the attribute should only be copied if the intention is `XATTR_OPERATION_INTENT_BACKUP`. That intention is distinct from the `XATTR_OPERATION_INTENT_SYNC` intention in that there is no desire to minimize the amount of metadata being moved.
		*/
		public static let onlyBackup = Self(rawValue: XATTR_FLAG_ONLY_BACKUP)

		public var rawValue: xattr_flags_t

		public init(rawValue: xattr_flags_t) {
			self.rawValue = rawValue
		}
	}
}
