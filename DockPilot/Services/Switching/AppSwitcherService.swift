import AppKit
import Combine
import Foundation

@MainActor
final class AppSwitcherService: ObservableObject {
    @Published private(set) var apps: [AppDescriptor] = []
    @Published var selectedIndex: Int = 0
    @Published var isPresented: Bool = false

    private let runningAppsService: RunningAppsProviding
    private let recentAppsStore: RecentAppsStore

    init(runningAppsService: RunningAppsProviding, recentAppsStore: RecentAppsStore) {
        self.runningAppsService = runningAppsService
        self.recentAppsStore = recentAppsStore
    }

    func reload(useRecentOrder: Bool) {
        let running = runningAppsService.runningApplications()
        if useRecentOrder {
            let order = Dictionary(uniqueKeysWithValues: recentAppsStore.bundleIdentifiers.enumerated().map { ($1, $0) })
            apps = running.sorted {
                (order[$0.bundleIdentifier] ?? Int.max) < (order[$1.bundleIdentifier] ?? Int.max)
            }
        } else {
            apps = running
        }
        selectedIndex = min(selectedIndex, max(0, apps.count - 1))
    }

    func present(useRecentOrder: Bool) {
        reload(useRecentOrder: useRecentOrder)
        isPresented = true
    }

    func dismiss() {
        isPresented = false
    }

    func moveSelection(delta: Int) {
        guard !apps.isEmpty else { return }
        selectedIndex = (selectedIndex + delta + apps.count) % apps.count
    }

    func select(_ app: AppDescriptor) {
        if let index = apps.firstIndex(of: app) {
            selectedIndex = index
        }
    }

    @discardableResult
    func activate(_ app: AppDescriptor) -> AppDescriptor? {
        select(app)
        return activateSelected()
    }

    @discardableResult
    func activateSelected() -> AppDescriptor? {
        guard apps.indices.contains(selectedIndex) else { return nil }
        let app = apps[selectedIndex]
        if let running = runningAppsService.application(for: app.bundleIdentifier) {
            running.activate(options: [.activateAllWindows, .activateIgnoringOtherApps])
            recentAppsStore.record(bundleIdentifier: app.bundleIdentifier)
        }
        dismiss()
        return app
    }
}
