// swift-tools-version:6.1
import PackageDescription

let package = Package(
	name: "ExtendedAttributes",
	platforms: [
		.macOS(.v11),
		.iOS(.v14),
		.tvOS(.v14),
		.watchOS(.v7),
		.visionOS(.v1)
	],
	products: [
		.library(
			name: "ExtendedAttributes",
			targets: [
				"ExtendedAttributes"
			]
		)
	],
	targets: [
		.target(
			name: "ExtendedAttributes"
		),
		.testTarget(
			name: "ExtendedAttributesTests",
			dependencies: [
				"ExtendedAttributes"
			]
		)
	]
)
