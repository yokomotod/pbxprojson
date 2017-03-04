import PackageDescription

let package = Package(
    name: "Pbxprojson",
    dependencies: [
    .Package(url: "git@github.com:Carthage/Commandant.git", majorVersion: 0, minor: 11)
    ]
)
