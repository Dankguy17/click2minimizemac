import AppKit
import Combine
import Foundation
import SwiftUI

@MainActor
final class AppCoordinator: ObservableObject {
    let settingsStore: SettingsStore
    let rulesStore: RulesStore
    let diagnosticsService: DiagnosticsService
    let eventTraceStore: EventTraceStore

    @Published private(set) var frontmostApp: AppDescriptor?
    @Published private(set) var frontmostAppState: AppState?
    @Published private(set) var runningApps: [AppDescriptor] = []

    private let statusBarController = StatusBarController()
    private let workspaceMonitor = WorkspaceMonitor()
    private let runningAppsService: RunningAppsProviding = RunningAppsService()
    private let frontmostAppService: FrontmostAppProviding = FrontmostAppService()
    private let stageManagerHeuristics = StageManagerHeuristics()
    private let spaceAwarenessService = SpaceAwarenessService()
    private let stateResolver = WindowStateResolver()
    private let eventTapManager = EventTapManager()
    private let axService: AccessibilityServing = AXService()
    private let recentAppsStore = RecentAppsStore()
    private let frameStore = WindowFrameStore()

    private lazy var logger = Logger(eventTraceStore: eventTraceStore)
    private lazy var windowQuery: WindowQuerying = AXWindowQuery(service: axService)
    private lazy var restoreEngine = RestoreEngine(frameStore: frameStore)
    private lazy var mutator = AXWindowMutator(
        query: windowQuery,
        service: axService,
        snapEngine: SnapEngine(),
        restoreEngine: restoreEngine,
        settingsProvider: { [weak self] in self?.settingsStore.settings ?? .default }
    )
    private lazy var fallbackExecutor = FallbackActionExecutor(appleScriptExecutor: AppleScriptExecutor())
    private lazy var actionExecutor = ActionExecutor(mutator: mutator, fallbackExecutor: fallbackExecutor)
    private lazy var mouseGestureEngine = MouseGestureEngine(windowQuery: windowQuery, spaceAwarenessService: spaceAwarenessService)
    private lazy var appSwitcherService = AppSwitcherService(runningAppsService: runningAppsService, recentAppsStore: recentAppsStore)
    private lazy var settingsWindowController = SettingsWindowController(coordinator: self)
    private lazy var appSwitcherWindowController = AppSwitcherWindowController(
        service: appSwitcherService,
        onDismiss: { [weak self] in
            self?.appSwitcherService.dismiss()
        }
    )
    private lazy var permissionsWindow: NSWindow = {
        let rootView = PermissionsOnboardingView(
            accessibilityGranted: axService.isTrusted(prompt: false),
            eventTapGranted: diagnosticsService.snapshot.eventTapEnabled,
            onRequestPermissions: { [weak self] in
                _ = self?.axService.isTrusted(prompt: true)
                self?.refreshPermissionState()
            },
            onContinue: { [weak self] in
                self?.permissionsWindow.orderOut(nil)
            }
        )
        let controller = NSHostingController(rootView: rootView)
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 460, height: 244),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = controller
        window.title = "Permissions"
        window.setContentSize(NSSize(width: 460, height: 244))
        window.contentMinSize = NSSize(width: 460, height: 244)
        window.contentMaxSize = NSSize(width: 640, height: 360)
        window.center()
        return window
    }()

    init() {
        let settingsStore = SettingsStore()
        let rulesStore = RulesStore()
        let diagnosticsService = DiagnosticsService()
        let eventTraceStore = EventTraceStore()
        self.settingsStore = settingsStore
        self.rulesStore = rulesStore
        self.diagnosticsService = diagnosticsService
        self.eventTraceStore = eventTraceStore
        self.eventTraceStore.retentionLimit = settingsStore.settings.diagnostics.retainedEventCount
    }

    func start() {
        configureStatusBar()
        configureWorkspace()
        refreshRunningApps()
        refreshFrontmostApp()
        refreshPermissionState()
        startEventTap()

        if settingsStore.settings.general.showPermissionOnboardingOnLaunch, !axService.isTrusted(prompt: false) {
            showPermissions()
        }
        if settingsStore.settings.general.openSettingsAtLaunch {
            openSettings()
        }
    }

    func stop() {
        workspaceMonitor.stop()
        eventTapManager.stop()
    }

    func openSettings() {
        settingsWindowController.showWindow(nil)
        settingsWindowController.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func showPermissions() {
        permissionsWindow.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func toggleFrontmostApp() {
        guard let app = frontmostApp else { return }
        executeDockToggle(for: app.bundleIdentifier, source: .menuBar)
    }

    func showAppSwitcher() {
        appSwitcherService.present(useRecentOrder: settingsStore.settings.appSwitcher.useRecentOrder)
        appSwitcherWindowController.present()
        diagnosticsService.update(plannedAction: ActionType.showSwitcherOverlay.label)
    }

    func dismissAppSwitcher() {
        appSwitcherService.dismiss()
        appSwitcherWindowController.dismiss()
    }

    func dismissAppSwitcherIfNeeded() {
        dismissAppSwitcher()
    }

    private func configureStatusBar() {
        statusBarController.onOpenSettings = { [weak self] in self?.openSettings() }
        statusBarController.onToggleFrontmost = { [weak self] in self?.toggleFrontmostApp() }
        statusBarController.onShowSwitcher = { [weak self] in self?.showAppSwitcher() }
        statusBarController.onShowPermissions = { [weak self] in self?.showPermissions() }
        statusBarController.onQuit = { NSApp.terminate(nil) }
        statusBarController.configure()
    }

    private func configureWorkspace() {
        workspaceMonitor.onFrontmostAppChanged = { [weak self] app in
            self?.frontmostApp = app
            self?.refreshFrontmostState()
            if let bundleIdentifier = app?.bundleIdentifier {
                self?.recentAppsStore.record(bundleIdentifier: bundleIdentifier)
            }
        }
        workspaceMonitor.onRunningAppsChanged = { [weak self] in
            self?.refreshRunningApps()
            self?.refreshFrontmostState()
        }
        workspaceMonitor.start()
    }

    private func startEventTap() {
        eventTapManager.onEvent = { [weak self] event in
            self?.handle(event: event)
        }
        let enabled = eventTapManager.start()
        diagnosticsService.update(eventTapEnabled: enabled)
        logger.log(.input, enabled ? "Event tap started" : "Event tap failed", metadata: [:])
    }

    private func refreshPermissionState() {
        diagnosticsService.update(accessibilityTrusted: axService.isTrusted(prompt: false))
    }

    private func refreshRunningApps() {
        runningApps = runningAppsService.runningApplications()
        appSwitcherService.reload(useRecentOrder: settingsStore.settings.appSwitcher.useRecentOrder)
    }

    private func refreshFrontmostApp() {
        frontmostApp = frontmostAppService.frontmostApplication()
        refreshFrontmostState()
    }

    private func refreshFrontmostState() {
        guard let frontmostApp,
              let application = runningAppsService.application(for: frontmostApp.bundleIdentifier) else {
            frontmostAppState = nil
            return
        }
        let windows = windowQuery.windows(for: application)
        let state = stateResolver.resolve(
            app: AppDescriptor(application),
            windows: windows,
            frontmostBundleIdentifier: frontmostApp.bundleIdentifier,
            stageManagerEnabled: stageManagerHeuristics.isStageManagerEnabled()
        )
        frontmostAppState = state
        diagnosticsService.update(
            frontmostAppName: frontmostApp.localizedName,
            frontmostBundleIdentifier: frontmostApp.bundleIdentifier,
            resolvedState: state.classification,
            windowCount: windows.count
        )
    }

    private func handle(event: GlobalInputEvent) {
        diagnosticsService.update(lastInputEvent: describe(event: event))
        guard settingsStore.settings.dockBehavior.isEnabled else { return }

        if let gesture = mouseGestureEngine.detectGesture(
            from: event,
            frontmostApp: frontmostApp,
            frontmostState: frontmostAppState,
            runningApps: runningApps,
            settings: settingsStore.settings
        ) {
            logger.log(.gesture, "Gesture detected", metadata: ["kind": gesture.kind.rawValue, "source": gesture.source.rawValue])
            if let bundleIdentifier = gesture.targetBundleIdentifier {
                execute(for: bundleIdentifier, gesture: gesture.kind, source: gesture.source)
            }
        }
    }

    private func executeDockToggle(for bundleIdentifier: String, source: ActionSource) {
        guard let application = runningAppsService.application(for: bundleIdentifier) else { return }
        let appDescriptor = AppDescriptor(application)
        let windows = windowQuery.windows(for: application)
        let state = stateResolver.resolve(
            app: appDescriptor,
            windows: windows,
            frontmostBundleIdentifier: frontmostApp?.bundleIdentifier,
            stageManagerEnabled: stageManagerHeuristics.isStageManagerEnabled()
        )
        let resolution = RulesEngine().resolve(for: appDescriptor, settings: settingsStore.settings, rules: rulesStore.rules)
        let plan = ActionPlanner().planDockToggle(for: state, settings: settingsStore.settings, matchedRule: resolution.rule)
        execute(plan: plan, application: application, state: state, source: source)
    }

    private func execute(for bundleIdentifier: String, gesture: GestureKind, source: ActionSource) {
        guard let application = runningAppsService.application(for: bundleIdentifier) else { return }
        let appDescriptor = AppDescriptor(application)
        let windows = windowQuery.windows(for: application)
        let state = stateResolver.resolve(
            app: appDescriptor,
            windows: windows,
            frontmostBundleIdentifier: frontmostApp?.bundleIdentifier,
            stageManagerEnabled: stageManagerHeuristics.isStageManagerEnabled()
        )
        let resolution = RulesEngine().resolve(for: appDescriptor, settings: settingsStore.settings, rules: rulesStore.rules)
        let plan: ActionPlan
        if gesture == .dockIconClick {
            plan = ActionPlanner().planDockToggle(for: state, settings: settingsStore.settings, matchedRule: resolution.rule)
        } else {
            plan = ActionPlanner().planGesture(kind: gesture, appState: state, matchedRule: resolution.rule, settings: settingsStore.settings)
        }
        execute(plan: plan, application: application, state: state, source: source)
    }

    private func execute(plan: ActionPlan, application: NSRunningApplication, state: AppState, source: ActionSource) {
        let effectivePlan = degradedPlanIfNeeded(plan, state: state, source: source)
        diagnosticsService.update(plannedAction: effectivePlan.steps.map(\.action.label).joined(separator: ", "))
        logger.log(.action, "Executing action plan", metadata: ["reason": effectivePlan.reason, "source": source.rawValue])

        if effectivePlan.steps.contains(where: { $0.action == .showSwitcherOverlay }) {
            showAppSwitcher()
            return
        }

        let result = actionExecutor.execute(plan: effectivePlan, for: application, windowState: state)
        diagnosticsService.record(result)
        if result.status == .success {
            refreshFrontmostState()
        }
        if settingsStore.settings.appSwitcher.dismissOnActivate {
            dismissAppSwitcher()
        }
    }

    private func degradedPlanIfNeeded(_ plan: ActionPlan, state: AppState, source: ActionSource) -> ActionPlan {
        guard let first = plan.steps.first?.action,
              stageManagerHeuristics.shouldDegrade(action: first, appState: state, settings: settingsStore.settings) else {
            return plan
        }

        logger.log(.action, "Degrading action due to Stage Manager heuristic", metadata: ["action": first.rawValue, "source": source.rawValue])
        return ActionPlan(
            source: plan.source,
            targetBundleIdentifier: plan.targetBundleIdentifier,
            steps: [.init(action: .activateApp)],
            reason: "Stage Manager safety path replaced disruptive action",
            requiresFallback: false
        )
    }

    private func describe(event: GlobalInputEvent) -> String {
        switch event.type {
        case .leftMouseDown:
            return "Left mouse down"
        case .leftMouseUp:
            return "Left mouse up"
        case .otherMouseDown:
            return "Auxiliary mouse down"
        case .otherMouseUp:
            return "Auxiliary mouse up"
        case .scrollWheel:
            return "Scroll wheel \(String(format: "%.1f", event.deltaY))"
        case .mouseMoved:
            return "Mouse moved"
        }
    }
}
