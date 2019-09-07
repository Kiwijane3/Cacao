// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Cacao",
	products: [
		.library(name: "Cacao", targets: ["Cacao"])
	],
    dependencies: [
        .package(
			url: "https://github.com/Kiwijane3/Cairo.git", from: "1.2.4"
        ),
        .package(
			url: "https://github.com/Kiwijane3/SDL.git", from: "1.1.0"
        ),
		.package(
			url: "https://github.com/Kiwijane3/Cassowary.git", from: "2.0.1"
		),
		.package(
			url: "https://github.com/Kiwijane3/Silica.git", from: "2.0.3"
		)
    ],
    targets: [
        .target(
            name: "Cacao",
            dependencies: [
                "Silica",
                "Cairo",
                "SDL",
				"Cassowary"
            ]
        )
	]
)
