import AppKit
import Foundation

protocol FrontmostAppProviding {
    func frontmostApplication() -> AppDescriptor?
}

struct FrontmostAppService: FrontmostAppProviding {
    func frontmostApplication() -> AppDescriptor? {
        NSWorkspace.shared.frontmostApplication.map(AppDescriptor.init)
    }
}
