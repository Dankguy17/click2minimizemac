# AGENTS.md — DockPilot

## Mission
Build **DockPilot**, a native macOS menu bar utility in Swift that reproduces and expands on Click2Minimize-style workflows:
- Dock icon click toggles minimize / restore / activate / hide
- Gesture-driven window control
- Vertical app switcher overlay
- Dock lock / dock-related behavior enhancements
- Stage Manager-aware interaction model
- Per-app rules and advanced settings
- Fast, stable, native-feeling operation

The implementation target is **personal-use quality but production-grade architecture**.

---

# 1. Product Definition

## 1.1 Primary user outcome
Eliminate friction in macOS window and Dock workflows so common actions can be done without aiming for traffic lights or using multiple utilities.

## 1.2 Non-goals
- No cloud sync
- No accounts
- No telemetry backend
- No App Store packaging requirement
- No dependence on private APIs for core functionality unless isolated as optional experimental code

## 1.3 Platform
- macOS
- Swift
- AppKit-first
- SwiftUI acceptable for settings panes only
- Apple Silicon first, but keep code portable where practical

---

# 2. Source-of-Truth Features

Implement all of the following as first-class product capabilities.

## 2.1 Dock behavior engine
- Click Dock icon to:
  - minimize app when already frontmost and visible
  - restore app when minimized
  - unhide app when hidden
  - activate app when in background
- Handle:
  - single-window apps
  - multi-window apps
  - modal windows
  - apps with zero standard windows
  - Finder edge cases

## 2.2 Window actions
- Minimize
- Restore / unminimize
- Hide app
- Unhide app
- Zoom / fill screen
- Fullscreen toggle
- Snap left/right
- Restore prior frame
- Bring all app windows front

## 2.3 Gesture system
- Mouse button combinations
- Double-click actions
- Scroll-wheel gestures
- Rock-wheel gestures
- Trackpad modifier-assisted gestures
- Title-bar scoped gestures
- Optional notch/title-area trigger behavior
- Per-gesture remapping

## 2.4 App switcher overlay
- Vertical app switcher
- Recent app ordering
- Keyboard navigation
- Mouse/scroll navigation
- Optional preview / metadata display
- Dismiss / activate / cycle behavior

## 2.5 Dock lock / display behavior
- Prevent unwanted dock interaction side effects where feasible
- Multi-monitor aware dock-related logic
- Rules for monitor-specific behavior if technically feasible without private APIs

## 2.6 Stage Manager / Spaces awareness
- Do not break expected behavior in fullscreen or Stage Manager contexts
- Recognize when actions should degrade gracefully
- Expose compatibility toggles in settings

## 2.7 Per-app rules
- Include/exclude apps
- Per-app click behavior
- Per-app gesture overrides
- Per-app snapping preferences
- Per-app fallback mode

## 2.8 Settings / diagnostics
- Menu bar UI
- Rich settings window
- Permission onboarding
- Debug panel:
  - current frontmost app
  - detected windows
  - state classification
  - last input event
  - action execution log
  - AX failures / fallback usage

---

# 3. Technical Principles

## 3.1 Architecture
Use a modular architecture with these layers:

1. **App Shell**
   - Menu bar lifecycle
   - Settings window
   - Permission onboarding
   - App state wiring

2. **Input Layer**
   - Global event taps
   - Gesture recognizers
   - Scroll / mouse / modifier handling

3. **Context Detection Layer**
   - Frontmost app tracking
   - Running app metadata
   - Window discovery
   - Display / space / fullscreen heuristics

4. **Action Layer**
   - Window manipulation
   - App activation / hiding / restore logic
   - Snap / frame restoration
   - Workspace/app switching

5. **Rules Engine**
   - Global and per-app settings
   - State-to-action mapping
   - Gesture routing

6. **Fallback Layer**
   - AppleScript fallback
   - Alternate AX traversal paths
   - Safe failure handling

7. **Persistence**
   - UserDefaults or local JSON
   - Versioned settings migration

8. **Diagnostics**
   - Structured logs
   - Event trace
   - Action outcomes
   - Feature flags

## 3.2 Preferred APIs
- Accessibility APIs (AXUIElement, AXObserver when useful)
- CGEvent taps
- NSWorkspace notifications
- NSScreen / display metadata
- AppleScript only as fallback
- Avoid private APIs for mainline behavior

## 3.3 Reliability rules
- Never crash on inaccessible app windows
- Time out AX calls where necessary
- Log and continue on failures
- Make feature degradation explicit in diagnostics
- Protect against recursive event injection loops

---

# 4. Repo Structure

Use this structure unless a small variation improves clarity.

```text
DockPilot/
  App/
    DockPilotApp.swift
    AppDelegate.swift
    StatusBarController.swift
    AppCoordinator.swift

  UI/
    Settings/
      SettingsWindowController.swift
      SettingsRootView.swift
      GeneralSettingsView.swift
      GesturesSettingsView.swift
      RulesSettingsView.swift
      DiagnosticsView.swift
    Overlay/
      AppSwitcherWindowController.swift
      AppSwitcherView.swift
      OverlayAnimator.swift
    Onboarding/
      PermissionsOnboardingView.swift

  Domain/
    Models/
      AppDescriptor.swift
      WindowDescriptor.swift
      AppState.swift
      WindowState.swift
      GestureDefinition.swift
      UserRule.swift
      ExecutionResult.swift
    Rules/
      RulesEngine.swift
      RuleMatcher.swift
      DefaultRules.swift
    Actions/
      ActionType.swift
      ActionPlan.swift
      ActionExecutor.swift

  Services/
    Input/
      EventTapManager.swift
      MouseGestureEngine.swift
      TrackpadGestureAdapter.swift
      ScrollGestureInterpreter.swift
      ModifierStateMonitor.swift
    Accessibility/
      AXService.swift
      AXWindowQuery.swift
      AXWindowMutator.swift
      AXAttributeReader.swift
    Workspace/
      WorkspaceMonitor.swift
      RunningAppsService.swift
      FrontmostAppService.swift
    Windows/
      WindowStateResolver.swift
      WindowFrameStore.swift
      SnapEngine.swift
      RestoreEngine.swift
    Switching/
      AppSwitcherService.swift
      RecentAppsStore.swift
    StageManager/
      StageManagerHeuristics.swift
      SpaceAwarenessService.swift
    Fallback/
      AppleScriptExecutor.swift
      FallbackActionExecutor.swift
    Persistence/
      SettingsStore.swift
      RulesStore.swift
      MigrationService.swift
    Diagnostics/
      Logger.swift
      EventTraceStore.swift
      DiagnosticsService.swift

  Resources/
    Assets.xcassets
    DefaultSettings.plist

  Tests/
    RulesEngineTests.swift
    GestureRoutingTests.swift
    AppStateResolverTests.swift
    SnapEngineTests.swift
    SettingsMigrationTests.swift

  README.md
  CHANGELOG.md
  AGENTS.md

  5. Agent Roles

Codex should simulate these roles and complete all of them in one pass.

5.1 Architect Agent

Responsible for:

final project structure
protocol boundaries
dependency direction
feature flags
avoiding tangled AppKit logic

Deliverables:

clean module boundaries
interfaces for AX, input, and rules
explicit limitations doc
5.2 macOS Systems Agent

Responsible for:

CGEvent taps
AX interaction
NSWorkspace integration
menu bar lifecycle
permission handling

Deliverables:

robust permission flow
safe input interception
event loop stability
5.3 Window Management Agent

Responsible for:

app/window state resolution
minimize/restore/hide logic
frame restore and snapping
multi-window decisioning

Deliverables:

deterministic action planner
window manipulation services
edge-case handling
5.4 Gesture Agent

Responsible for:

mouse combo gestures
double-click handling
scroll and rock-wheel gestures
title-bar/notch-area scoping

Deliverables:

configurable gesture definitions
gesture conflict resolution
low-latency recognition
5.5 Overlay/UI Agent

Responsible for:

vertical app switcher overlay
settings UI
diagnostics panel
onboarding

Deliverables:

native, minimal UI
fast overlay rendering
clear settings hierarchy
5.6 QA/Hardening Agent

Responsible for:

tests of pure logic modules
fallback behavior validation
debug logging quality
failure-mode documentation

Deliverables:

tests
known limitations
stability checklist
5.7 Documentation Agent

Responsible for:

README
setup instructions
permissions guide
feature matrix
changelog

Deliverables:

crisp docs
realistic limitation notes
quick start guide
6. Implementation Phases

Codex should implement phases in order, but output the final integrated repository state.

Phase 1 — Foundation

Build:

menu bar app shell
settings window shell
permission onboarding
logging
settings persistence
workspace/frontmost app monitoring

Exit criteria:

app launches
menu bar item works
settings persist
diagnostics can display app metadata
Phase 2 — App and Window State

Build:

app descriptors
window descriptors
AX window queries
state resolver

State classifications must include:

activeVisible
activeMinimized
activeHidden
backgroundVisible
backgroundMinimized
backgroundHidden
mixed
unknown

Exit criteria:

diagnostic panel shows accurate best-effort classification
Phase 3 — Core Dock Toggle Engine

Build:

action planner for Dock-click semantics
minimize/restore/activate/hide logic
multi-window policy
Finder handling
AppleScript fallback path

Exit criteria:

deterministic state-to-action mapping
simulated Dock-trigger entry point callable internally
Phase 4 — Input and Gesture Engine

Build:

global input tap manager
modifier monitor
gesture routing
title-bar area targeting heuristics
double-click, button-combo, scroll, rock-wheel gestures

Exit criteria:

gestures produce structured actions
conflicts resolved predictably
Phase 5 — Snapping and Restore

Build:

snap engine
frame memory
restore engine
left/right/fill/restore actions

Exit criteria:

windows can be snapped and restored reliably
Phase 6 — App Switcher Overlay

Build:

recent apps store
vertical overlay
activation/cycling logic
keyboard and scroll controls

Exit criteria:

switcher overlay works independently of Dock toggle features
Phase 7 — Per-App Rules

Build:

inclusion/exclusion
gesture overrides
app-specific policies
settings UI to edit rules

Exit criteria:

rule resolution is test-covered and deterministic
Phase 8 — Diagnostics and Hardening

Build:

event trace viewer
action outcome logs
settings export/import if easy
known issues panel

Exit criteria:

app failures are inspectable
docs match actual behavior
7. Functional Specifications
7.1 App state model

Implement a resolver that consumes:

frontmost app
running app metadata
window list
AX minimized attributes
hidden status
fullscreen/space heuristics

It must return:

app state
confidence score or reason string
actionable windows set
7.2 Action planning

Create a planner:

Input: app state + rules + gesture/action source
Output: action plan

Planner must decide:

activate app
unhide app
restore one/all windows
minimize one/all windows
no-op with reason
fallback required
7.3 Multi-window policies

Support policies:

allWindows
frontWindowOnly
lastFocusedWindow
cycleInsteadOfMinimize
7.4 Gesture routing

Map gesture definitions to actions with:

enable/disable flag
scope
modifiers
target constraints
per-app overrides
7.5 Overlay behavior

Switcher should support:

recent apps
active app highlight
dismissal on escape/click-away
smooth but simple animation
keyboard arrows / scroll navigation
8. Edge Cases That Must Be Handled
Finder with no regular document windows
Apps with hidden but not minimized windows
Minimized windows in fullscreen spaces
Electron apps with odd AX hierarchies
Apps with floating panels
Mission Control interference
Stage Manager interactions
Multiple monitors with active spaces
Permissions revoked after launch
Event tap disabled by system
Recursive actions triggered by own synthetic events
Apps that reject AX mutations

When exact behavior is not possible, degrade gracefully and log why.

9. Diagnostics Requirements

Diagnostics panel must show:

Accessibility permission status
Event tap status
Frontmost app
Last hovered/target app if available
Resolved app state
Window count
Planned action
Executed action
Fallback path used
Last error

Logging should use structured categories:

input
gesture
rules
ax
action
ui
fallback
10. Settings Requirements

Settings categories:

General
Dock Behavior
Gestures
App Switcher
Snapping
Per-App Rules
Diagnostics
Experimental

Important toggles:

enable core dock toggle
single vs double click semantics
minimize vs hide preference
all windows vs front window
stage manager compatibility mode
fullscreen safety mode
show overlay previews
enable AppleScript fallback
verbose logging
11. Testing Strategy

Write tests for pure logic only; avoid brittle UI tests unless trivial.

Required tests:

RulesEngineTests
AppStateResolverTests
ActionPlannerTests
GestureRoutingTests
SnapEngineTests
SettingsMigrationTests

Test scenarios:

frontmost visible app clicked
hidden app clicked
minimized app clicked
multi-window app with different policies
excluded app
fallback path selected
gesture overridden by per-app rule
restoration after snap
12. README Requirements

README must include:

What DockPilot is
Feature list
Architecture overview
Permissions setup
Build instructions
How settings are stored
Known limitations
Debugging tips
Roadmap / future experiments

Do not oversell. Be explicit about:

macOS permission constraints
why some behaviors are heuristic
what is experimental
13. CHANGELOG Requirements

Create CHANGELOG.md with:

initial release entry
feature bullets by subsystem
known limitations section
14. Definition of Done

The task is done only when the repo contains:

compilable Xcode project
menu bar utility app shell
modular services and domain layer
settings UI
diagnostics UI
rules engine
gesture engine
app switcher overlay
snap/restore engine
tests for logic modules
README
CHANGELOG

If a feature cannot be implemented perfectly, ship:

best-effort implementation
explicit TODO
limitation note in README
diagnostic trace support
15. Execution Instructions to Codex
Do not stop at scaffolding
Do not leave placeholder files unless required
Prefer working implementations over speculative abstraction
Keep code readable and idiomatic
Comment only where behavior is non-obvious
Use protocols for replaceable low-level services
Keep fallback logic isolated
Avoid unnecessary dependencies
Output the final repo state as if completing the project in one pass