import Foundation

enum WindowState: String, Codable, CaseIterable, Hashable {
    case visible
    case minimized
    case hidden
    case fullscreen
    case unknown
}
