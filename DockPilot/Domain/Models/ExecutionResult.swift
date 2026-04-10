import Foundation

enum ExecutionStatus: String, Codable, CaseIterable, Hashable {
    case success
    case failure
    case noOp
}

struct ExecutionResult: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var timestamp: Date
    var action: ActionType
    var status: ExecutionStatus
    var usedFallback: Bool
    var message: String

    init(
        id: UUID = UUID(),
        timestamp: Date = .now,
        action: ActionType,
        status: ExecutionStatus,
        usedFallback: Bool,
        message: String
    ) {
        self.id = id
        self.timestamp = timestamp
        self.action = action
        self.status = status
        self.usedFallback = usedFallback
        self.message = message
    }
}
