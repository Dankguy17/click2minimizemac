import CoreGraphics
import Foundation

struct WindowDescriptor: Codable, Hashable, Identifiable, Sendable {
    var id: String
    var title: String
    var appBundleIdentifier: String
    var ownerProcessIdentifier: Int32
    var frame: CGRect
    var isMain: Bool
    var isKey: Bool
    var isMinimized: Bool
    var isVisible: Bool
    var isFullscreen: Bool
    var isStandardWindow: Bool
    var role: String?
    var subrole: String?
}
