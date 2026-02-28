// swift-tools-version: 5.9

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Unseen",
    platforms: [
        .iOS("26.0")
    ],
    products: [
        .iOSApplication(
            name: "Unseen",
            targets: ["AppModule"],
            teamIdentifier: "66NQ99A3NZ",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .placeholder(icon: .binoculars),
            accentColor: .presetColor(.orange),
            supportedDeviceFamilies: [
                .pad,
                .phone
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeLeft,
                .landscapeRight,
                .portraitUpsideDown(.when(deviceFamilies: [.pad]))
            ],
            appCategory: .education,
            additionalInfoPlistContentFilePath: "Supporting/Info.plist"
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: "."
        )
    ]
)
