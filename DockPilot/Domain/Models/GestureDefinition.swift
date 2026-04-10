import Foundation

enum GestureKind: String, Codable, CaseIterable, Hashable, Identifiable {
    case dockIconClick
    case titleBarDoubleClick
    case scrollUp
    case scrollDown
    case rockerLeft
    case rockerRight
    case notchClick
    case trackpadModifierSwipe

    var id: String { rawValue }
}

enum GestureScope: String, Codable, CaseIterable, Hashable, Identifiable {
    case dock
    case titleBar
    case notchArea
    case global

    var id: String { rawValue }
}

enum KeyboardModifier: String, Codable, CaseIterable, Hashable, Identifiable {
    case command
    case option
    case control
    case shift
    case function

    var id: String { rawValue }
}

enum GestureTargetConstraint: String, Codable, CaseIterable, Hashable, Identifiable {
    case any
    case dockIcon
    case standardWindow
    case titleBar
    case notchArea

    var id: String { rawValue }
}

struct GestureDefinition: Codable, Hashable, Identifiable, Sendable {
    var id: UUID
    var name: String
    var isEnabled: Bool
    var kind: GestureKind
    var scope: GestureScope
    var requiredModifiers: [KeyboardModifier]
    var targetConstraint: GestureTargetConstraint
    var action: ActionType

    static let defaults: [GestureDefinition] = [
        GestureDefinition(
            id: UUID(uuidString: "11111111-1111-1111-1111-111111111111") ?? UUID(),
            name: "Dock Click Toggle",
            isEnabled: true,
            kind: .dockIconClick,
            scope: .dock,
            requiredModifiers: [],
            targetConstraint: .dockIcon,
            action: .dockSemanticToggle
        ),
        GestureDefinition(
            id: UUID(uuidString: "22222222-2222-2222-2222-222222222222") ?? UUID(),
            name: "Title Bar Double Click",
            isEnabled: true,
            kind: .titleBarDoubleClick,
            scope: .titleBar,
            requiredModifiers: [],
            targetConstraint: .titleBar,
            action: .minimizeFrontWindow
        ),
        GestureDefinition(
            id: UUID(uuidString: "33333333-3333-3333-3333-333333333333") ?? UUID(),
            name: "Scroll Up To Fill",
            isEnabled: true,
            kind: .scrollUp,
            scope: .titleBar,
            requiredModifiers: [.option],
            targetConstraint: .titleBar,
            action: .fill
        ),
        GestureDefinition(
            id: UUID(uuidString: "44444444-4444-4444-4444-444444444444") ?? UUID(),
            name: "Scroll Down To Restore",
            isEnabled: true,
            kind: .scrollDown,
            scope: .titleBar,
            requiredModifiers: [.option],
            targetConstraint: .titleBar,
            action: .restoreFrame
        ),
        GestureDefinition(
            id: UUID(uuidString: "55555555-5555-5555-5555-555555555555") ?? UUID(),
            name: "Rocker Left",
            isEnabled: true,
            kind: .rockerLeft,
            scope: .global,
            requiredModifiers: [.control],
            targetConstraint: .any,
            action: .snapLeft
        ),
        GestureDefinition(
            id: UUID(uuidString: "66666666-6666-6666-6666-666666666666") ?? UUID(),
            name: "Rocker Right",
            isEnabled: true,
            kind: .rockerRight,
            scope: .global,
            requiredModifiers: [.control],
            targetConstraint: .any,
            action: .snapRight
        ),
    ]
}
