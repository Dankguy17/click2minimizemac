import Combine
import Foundation

struct EventTraceEntry: Identifiable, Hashable, Sendable {
    var id: UUID
    var timestamp: Date
    var category: LogCategory
    var message: String
    var metadata: [String: String]

    init(id: UUID = UUID(), timestamp: Date = .now, category: LogCategory, message: String, metadata: [String: String]) {
        self.id = id
        self.timestamp = timestamp
        self.category = category
        self.message = message
        self.metadata = metadata
    }
}

@MainActor
final class EventTraceStore: ObservableObject {
    @Published private(set) var entries: [EventTraceEntry] = []
    var retentionLimit: Int = 200

    func append(category: LogCategory, message: String, metadata: [String: String] = [:]) {
        entries.insert(
            EventTraceEntry(category: category, message: message, metadata: metadata),
            at: 0
        )
        if entries.count > retentionLimit {
            entries = Array(entries.prefix(retentionLimit))
        }
    }

    func clear() {
        entries.removeAll()
    }
}
