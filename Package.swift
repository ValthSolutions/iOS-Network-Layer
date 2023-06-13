// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Network-Layer",
    platforms: [
        .iOS(.v16)
    ],
    
    products: [
        .library(
            name: "NetworkInterface",
            targets: ["NetworkInterface"]),
        .library(
            name: "Networking",
            targets: ["Networking"]),
        .library(
            name: "SampleApp",
            targets: ["SampleApp"]),
    ],
    
    dependencies: [ 
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
    ],
    
    targets: [
        .target(
            name: "SampleApp",
            dependencies: [
            "NetworkInterface", "Networking"
            ]),
        .target(
            name: "NetworkInterface",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
            ]),
        .target(
            name: "Networking",
            dependencies: [
                "NetworkInterface",
                .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),
     
    ]
)
