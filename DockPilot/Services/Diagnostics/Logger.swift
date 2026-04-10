import Foundation
import OSLog

enum LogCategory: String, Codable, CaseIterable, Hashable, Identifiable {
    case input
    case gesture
    case rules
    case ax
    case action
    case ui
    case fallback
    case workspace
    case diagnostics

    var id: String { rawValue }
}

protocol Logging {
    func log(_ category: LogCategory, _ message: String, metadata: [String: String])
}

final class Logger: Logging {
    private let subsystem = Bundle.main.bundleIdentifier ?? "DockPilot"
    private let eventTraceStore: EventTraceStore

    init(eventTraceStore: EventTraceStore) {
        self.eventTraceStore = eventTraceStore
    }

    func log(_ category: LogCategory, _ message: String, metadata: [String: String] = [:]) {
        let oslog = OSLog(subsystem: subsystem, category: category.rawValue)
        let renderedMessage = metadata.isEmpty ? message : "\(message) \(metadata.description)"
        os_log("%{public}@", log: oslog, type: .info, renderedMessage)
        Task { @MainActor in
            eventTraceStore.append(category: category, message: message, metadata: metadata)
        }
    }
}
