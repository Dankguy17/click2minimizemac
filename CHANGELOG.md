# Changelog

## 0.1.0 - 2026-04-09

Initial DockPilot repository build.

### App Shell

- Added an AppKit-first menu bar app shell with `AppDelegate`, `AppCoordinator`, and `StatusBarController`.
- Added a custom settings window and permission onboarding window.
- Added a shared `DockPilot` scheme with build and test actions configured for command-line use.

### Domain And Rules

- Added app, window, gesture, rule, execution, and settings models.
- Added a deterministic dock-toggle action planner and rule resolution pipeline.
- Added default Finder-specific seed rules and multi-window policy support.

### Accessibility And Window Management

- Added Accessibility service, attribute reader, window query, and window mutator layers.
- Added app/window state resolution, snap calculations, frame restore memory, and fullscreen mutation support.
- Added AppleScript fallback isolation for activation and hide/unhide recovery cases.

### Input And Gesture Engine

- Added a listen-only global event tap manager.
- Added gesture detection for Dock click inference, title bar double-click, title bar scroll, rocker gestures, notch-area clicks, and modifier-assisted trackpad interpretation.
- Added Stage Manager heuristics and display-aware targeting helpers.

### Overlay And Settings UI

- Added a vertical app switcher overlay with keyboard navigation and recent-app ordering.
- Added SwiftUI settings panes for general behavior, gestures, per-app rules, and diagnostics.
- Added a diagnostics pane with permission status, resolved app state, action history, and event tracing.

### Persistence And Diagnostics

- Added `UserDefaults`-backed settings, rules, and recent-app stores.
- Added settings migration support and bundled default settings in `DefaultSettings.plist`.
- Added structured logging categories and an in-app event trace store.

### Tests

- Added `RulesEngineTests`
- Added `AppStateResolverTests`
- Added `ActionPlannerTests`
- Added `GestureRoutingTests`
- Added `SnapEngineTests`
- Added `SettingsMigrationTests`

### Known Limitations

- Dock icon click handling is heuristic because public macOS APIs do not provide a supported interception path.
- Stage Manager, Spaces, and monitor-specific Dock behaviors are safety-biased best-effort implementations.
- Some apps with irregular Accessibility trees may require fallback behavior or may expose incomplete window metadata.
