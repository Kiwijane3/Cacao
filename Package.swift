// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "Cacao",
	products: [
		.library(name: "Cacao", targets: ["Cacao"])
	],
    dependencies: [
        .package(
            path: "https://github.com/Kiwijane3/Silica.git"
        ),
        .package(
            path: "https://github.com/Kiwijane3/Cairo.git"
        ),
        .package(
            path: "https://github.com/PureSwift/SDL.git"
        ),
		.package(
			path: "https://github.com/Kiwijane3/Cassowary.git"
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
