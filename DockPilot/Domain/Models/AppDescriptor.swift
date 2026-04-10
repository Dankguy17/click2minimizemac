import Foundation

struct AppDescriptor: Codable, Hashable, Identifiable, Sendable {
    var bundleIdentifier: String
    var localizedName: String
    var processIdentifier: Int32
    var isHidden: Bool
    var isFrontmost: Bool
    var activationPolicy: String
    var launchDate: Date?

    var id: String { bundleIdentifier }

    static let finder = AppDescriptor(
        bundleIdentifier: "com.apple.finder",
        localizedName: "Finder",
        processIdentifier: 0,
        isHidden: false,
        isFrontmost: false,
        activationPolicy: "regular",
        launchDate: nil
    )
}
