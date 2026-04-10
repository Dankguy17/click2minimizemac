import ApplicationServices
import AppKit
import Foundation

struct GlobalInputEvent: Sendable {
    enum EventType: Sendable {
        case leftMouseDown
        case leftMouseUp
        case otherMouseDown
        case otherMouseUp
        case scrollWheel
        case mouseMoved
    }

    var type: EventType
    var location: CGPoint
    var clickCount: Int
    var buttonNumber: Int
    var deltaY: Double
    var modifiers: Set<KeyboardModifier>
}

@MainActor
final class EventTapManager {
    var onEvent: ((GlobalInputEvent) -> Void)?
    private let modifierStateMonitor = ModifierStateMonitor()
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?

    private static let mask: CGEventMask =
        (1 << CGEventType.leftMouseDown.rawValue) |
        (1 << CGEventType.leftMouseUp.rawValue) |
        (1 << CGEventType.otherMouseDown.rawValue) |
        (1 << CGEventType.otherMouseUp.rawValue) |
        (1 << CGEventType.scrollWheel.rawValue) |
        (1 << CGEventType.mouseMoved.rawValue)

    func start() -> Bool {
        let callback: CGEventTapCallBack = { _, type, event, refcon in
            let manager = Unmanaged<EventTapManager>.fromOpaque(refcon!).takeUnretainedValue()
            manager.handle(event: event, type: type)
            return Unmanaged.passUnretained(event)
        }

        guard let tap = CGEvent.tapCreate(
            tap: .cgSessionEventTap,
            place: .headInsertEventTap,
            options: .listenOnly,
            eventsOfInterest: Self.mask,
            callback: callback,
            userInfo: Unmanaged.passUnretained(self).toOpaque()
        ) else {
            return false
        }

        eventTap = tap
        runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        if let runLoopSource {
            CFRunLoopAddSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        CGEvent.tapEnable(tap: tap, enable: true)
        return true
    }

    func stop() {
        if let tap = eventTap {
            CGEvent.tapEnable(tap: tap, enable: false)
        }
        if let runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), runLoopSource, .commonModes)
        }
        eventTap = nil
        runLoopSource = nil
    }

    private func handle(event: CGEvent, type: CGEventType) {
        guard let mappedType = map(type) else { return }
        let input = GlobalInputEvent(
            type: mappedType,
            location: event.location,
            clickCount: Int(event.getIntegerValueField(.mouseEventClickState)),
            buttonNumber: Int(event.getIntegerValueField(.mouseEventButtonNumber)),
            deltaY: event.getDoubleValueField(.scrollWheelEventDeltaAxis1),
            modifiers: modifierStateMonitor.modifiers(from: NSEvent.ModifierFlags(rawValue: UInt(event.flags.rawValue)))
        )
        onEvent?(input)
    }

    private func map(_ type: CGEventType) -> GlobalInputEvent.EventType? {
        switch type {
        case .leftMouseDown:
            return .leftMouseDown
        case .leftMouseUp:
            return .leftMouseUp
        case .otherMouseDown:
            return .otherMouseDown
        case .otherMouseUp:
            return .otherMouseUp
        case .scrollWheel:
            return .scrollWheel
        case .mouseMoved:
            return .mouseMoved
        default:
            return nil
        }
    }
}
