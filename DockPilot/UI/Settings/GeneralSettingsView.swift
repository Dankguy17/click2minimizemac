import SwiftUI

struct GeneralSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                generalSection
                dockSection
                switcherSection
                snappingSection
                experimentalSection
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var generalSection: some View {
        GroupBox("General") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Open settings at launch", isOn: settingsBinding(\.general.openSettingsAtLaunch))
                Toggle("Show permission onboarding on launch", isOn: settingsBinding(\.general.showPermissionOnboardingOnLaunch))
                Toggle("Verbose logging", isOn: settingsBinding(\.diagnostics.verboseLogging))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var dockSection: some View {
        GroupBox("Dock Behavior") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Enable core Dock toggle", isOn: settingsBinding(\.dockBehavior.isEnabled))
                Toggle("Single click uses semantic toggle", isOn: settingsBinding(\.dockBehavior.singleClickSemanticToggle))
                Toggle("Prefer hide over minimize", isOn: settingsBinding(\.dockBehavior.prefersHideOverMinimize))
                Toggle("Stage Manager compatibility mode", isOn: settingsBinding(\.dockBehavior.stageManagerCompatibilityMode))
                Toggle("Fullscreen safety mode", isOn: settingsBinding(\.dockBehavior.fullscreenSafetyMode))
                Toggle("Enable AppleScript fallback", isOn: settingsBinding(\.dockBehavior.enableAppleScriptFallback))

                Picker("Multi-window policy", selection: settingsBinding(\.dockBehavior.multiWindowPolicy)) {
                    ForEach(MultiWindowPolicy.allCases) { policy in
                        Text(policy.label).tag(policy)
                    }
                }
                .pickerStyle(.menu)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var switcherSection: some View {
        GroupBox("App Switcher") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Use recent app ordering", isOn: settingsBinding(\.appSwitcher.useRecentOrder))
                Toggle("Show preview placeholders", isOn: settingsBinding(\.appSwitcher.showPreviews))
                Toggle("Show metadata", isOn: settingsBinding(\.appSwitcher.showMetadata))
                Toggle("Dismiss on activate", isOn: settingsBinding(\.appSwitcher.dismissOnActivate))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var snappingSection: some View {
        GroupBox("Snapping") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Remember original frames", isOn: settingsBinding(\.snapping.rememberFrames))
                Toggle("Use visible frame instead of full screen bounds", isOn: settingsBinding(\.snapping.useVisibleFrame))
                HStack {
                    Text("Padding")
                    Slider(value: settingsBinding(\.snapping.padding), in: 0...30, step: 1)
                    Text("\(Int(coordinator.settingsStore.settings.snapping.padding)) pt")
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var experimentalSection: some View {
        GroupBox("Experimental") {
            VStack(alignment: .leading, spacing: 12) {
                Toggle("Infer Dock icon hits via Accessibility", isOn: settingsBinding(\.experimental.enableDockIconInference))
                Toggle("Enable Dock lock heuristics", isOn: settingsBinding(\.experimental.enableDockLockHeuristics))
                Toggle("Enable workspace cycling actions", isOn: settingsBinding(\.experimental.enableWorkspaceCycling))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func settingsBinding<Value>(_ keyPath: WritableKeyPath<DockPilotSettings, Value>) -> Binding<Value> {
        Binding(
            get: { coordinator.settingsStore.settings[keyPath: keyPath] },
            set: { coordinator.settingsStore.settings[keyPath: keyPath] = $0 }
        )
    }
}
