// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [
        .iOS(.v14)
    ],
    
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["NetworkLayer"])
    ],
    
    dependencies: [ 
        .package(url: "https://github.com/Alamofire/Alamofire.git", .upToNextMajor(from: "5.6.1")),
    ],
    
    targets: [
        .target(
            name: "INetwork",
            dependencies: [
                .product(name: "Alamofire", package: "Alamofire"),
            ]),
        .target(
            name: "NetworkLayer",
            dependencies: [
                "INetwork",
                .product(name: "Alamofire", package: "Alamofire"),
            ]
        ),
     
    ]
)
