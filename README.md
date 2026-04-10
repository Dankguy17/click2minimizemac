# DockPilot

DockPilot is a personal-use macOS menu bar utility built in Swift with an AppKit-first architecture. It is designed to reproduce Click2Minimize-style workflows and extend them with gesture routing, a vertical app switcher, window snapping, per-app rules, diagnostics, and fallback behavior that stays transparent when macOS limits exact control.

The implementation favors correctness, resilience, and observability over flashy UI. Where macOS does not expose a perfect public API path, DockPilot uses best-effort Accessibility heuristics, clearly isolated fallbacks, and explicit diagnostics so failures are inspectable instead of silent.

## Shipped Features

- Menu bar lifecycle with status item actions for settings, permissions, frontmost-app toggling, and the app switcher.
- Accessibility-backed window discovery and mutation for minimize, restore, hide, unhide, raise, fullscreen toggle, snapping, and frame restoration.
- Dock semantic toggle planner that distinguishes active, background, hidden, minimized, mixed, and unknown app states.
- Global input pipeline using a listen-only event tap for Dock click heuristics, title bar double-click, scroll gestures, rocker gestures, notch-area triggers, and modifier-assisted trackpad gestures.
- Vertical app switcher overlay with recent-app ordering, keyboard navigation, and activation.
- Per-app rules for exclusion, action overrides, fallback mode, and multi-window policy overrides.
- Structured diagnostics with permission status, event tap status, frontmost app metadata, resolved state, recent execution results, and an event trace.
- AppleScript fallback isolation for cases where Accessibility mutation fails.
- Pure logic test coverage for rules, state resolution, action planning, gesture routing, snapping math, and settings migration.

## Architecture

DockPilot is organized around a layered design:

1. `DockPilot/App`
   App delegate, menu bar lifecycle, status item, top-level coordinator.
2. `DockPilot/UI`
   SwiftUI settings panes, onboarding window, and the app switcher overlay hosted in AppKit windows.
3. `DockPilot/Domain`
   App/window models, action planning, rules resolution, and pure policy logic.
4. `DockPilot/Services`
   Accessibility, workspace monitoring, input taps, snapping, restore, fallback execution, persistence, recent apps, Stage Manager heuristics, and diagnostics.
5. `DockPilotTests`
   Pure logic tests only. No brittle UI automation is required to validate the planner and rule engine.

Dependency direction is intentionally one-way: UI depends on the coordinator, the coordinator depends on services and domain logic, and platform-specific services are hidden behind protocols where replacement or mocking is useful.

## Permissions

DockPilot needs macOS permissions to do useful work:

- Accessibility: required for window discovery, minimize/restore mutation, and Dock/title bar heuristics.
- Input Monitoring / event tap approval: required for global gesture detection on mouse and scroll input.
- Apple Events automation: only used as a fallback path when enabled in settings.

On first launch, DockPilot opens a permissions window if Accessibility is not granted. The app does not use private APIs for the mainline behavior.

## Build And Run

Requirements:

- Xcode 16 or newer
- macOS 14 or newer
- Apple Silicon is the primary target, but the project does not intentionally block Intel builds

Commands:

```bash
xcodebuild -project click2minimizemacos.xcodeproj -scheme DockPilot -destination 'platform=macOS' build
xcodebuild -project click2minimizemacos.xcodeproj -scheme DockPilot -destination 'platform=macOS' test
```

Open the project in Xcode if you prefer:

```bash
open click2minimizemacos.xcodeproj
```

## Settings Storage

DockPilot stores configuration locally only.

- App settings are stored in `UserDefaults` under `DockPilot.settings`.
- Per-app rules are stored in `UserDefaults` under `DockPilot.rules`.
- Recent apps are stored in `UserDefaults` under `DockPilot.recentApps`.
- The bundled baseline configuration lives in [`DockPilot/Resources/DefaultSettings.plist`](/Users/anishmadishetty/Documents/click2minimizemac/click2minimizemacos/DockPilot/Resources/DefaultSettings.plist).

There is no cloud sync, account system, telemetry backend, or network dependency.

## Feature Notes

### Dock Toggle Engine

DockPilot resolves app state from:

- frontmost app metadata
- hidden status
- Accessibility windows
- minimized flags
- fullscreen heuristics
- Stage Manager awareness

The resulting classification feeds a deterministic planner that decides whether to activate, unhide, restore, minimize, or no-op.

### Gestures

The input layer currently supports:

- Dock click inference through Accessibility hit-testing of the Dock process
- title bar double-click
- title bar scroll gestures
- rocker gestures
- notch-area click heuristics
- modifier-assisted trackpad scroll interpretation

Gesture mapping is configurable in settings, and per-app rules can override specific gesture actions.

### App Switcher

The vertical switcher is independent of Dock toggling and can be invoked from the menu bar. It uses recent-app ordering when enabled, supports arrow-key navigation, and activates the selected app on Return.

### Snapping And Restore

Snapping uses public screen bounds and remembers prior window frames in memory for restore operations. Left, right, fill, and restore are implemented through Accessibility position/size mutations.

## Known Limitations

- Exact interception of true Dock icon clicks is not available through a public API. DockPilot uses Accessibility hit-testing against the Dock process, which is best-effort and may miss or misclassify some icons.
- Finder, Electron apps, floating panels, and apps with unusual Accessibility trees may expose incomplete or nonstandard window metadata.
- Stage Manager and fullscreen handling use public heuristics only. DockPilot intentionally degrades to safer activation behavior when a disruptive action looks risky.
- Mission Control, Spaces, and monitor-specific Dock behavior are limited by public API visibility. The project isolates these areas as heuristics rather than pretending they are exact.
- AppleScript fallback is intentionally conservative. It is a compatibility escape hatch, not a primary execution path.

## Debugging Tips

- Open the Diagnostics settings page to inspect permissions, frontmost app state, recent action results, and the event trace.
- If gestures stop firing, verify both Accessibility permission and event tap availability.
- If a target app does not minimize or restore correctly, enable verbose logging and check whether the diagnostic trace shows AX failures or fallback usage.
- If tests fail under a host app launch, DockPilot disables its coordinator bootstrap during XCTest to avoid menu bar and event tap side effects.

## Roadmap / Future Experiments

- Stronger Dock icon identification with richer AX metadata matching and cached app icon/title signatures.
- More nuanced multi-window restore policies, including last-focused window tracking across sessions.
- Optional import/export for settings and rules.
- Richer overlay previews and workspace-aware switching metadata.
- Additional safe heuristics for multi-display Dock behavior without private APIs.

## Personal-Use Scope

DockPilot is intentionally scoped as a personal utility with production-grade internals. The architecture is prepared for extension, but the project does not claim App Store readiness or perfect parity with utilities that depend on private APIs.
