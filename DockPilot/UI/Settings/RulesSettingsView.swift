import SwiftUI

struct RulesSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var newBundleIdentifier = ""
    @State private var newAppName = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            GroupBox("Add Rule") {
                HStack {
                    TextField("Bundle Identifier", text: $newBundleIdentifier)
                    TextField("App Name", text: $newAppName)
                    Button("Add") {
                        addRule()
                    }
                    .disabled(newBundleIdentifier.isEmpty || newAppName.isEmpty)
                }
            }

            List {
                ForEach(Array(coordinator.rulesStore.rules.enumerated()), id: \.element.id) { index, rule in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(rule.appName)
                                .font(.headline)
                            Spacer()
                            Toggle("Enabled", isOn: Binding(
                                get: { coordinator.rulesStore.rules[index].isEnabled },
                                set: { coordinator.rulesStore.rules[index].isEnabled = $0 }
                            ))
                            .labelsHidden()
                        }
                        Text(rule.bundleIdentifier)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Toggle("Exclude from Dock toggle", isOn: Binding(
                            get: { coordinator.rulesStore.rules[index].isExcluded },
                            set: { coordinator.rulesStore.rules[index].isExcluded = $0 }
                        ))

                        Picker(
                            "Preferred Dock Action",
                            selection: Binding<ActionType?>(
                                get: { coordinator.rulesStore.rules[index].preferredDockAction },
                                set: { coordinator.rulesStore.rules[index].preferredDockAction = $0 }
                            )
                        ) {
                            Text("Inherit").tag(ActionType?.none)
                            ForEach(ActionType.allCases.filter { $0 != .noOp }) { action in
                                Text(action.label).tag(ActionType?.some(action))
                            }
                        }

                        Picker(
                            "Multi-window Policy",
                            selection: Binding<MultiWindowPolicy?>(
                                get: { coordinator.rulesStore.rules[index].multiWindowPolicy },
                                set: { coordinator.rulesStore.rules[index].multiWindowPolicy = $0 }
                            )
                        ) {
                            Text("Inherit").tag(MultiWindowPolicy?.none)
                            ForEach(MultiWindowPolicy.allCases) { policy in
                                Text(policy.label).tag(MultiWindowPolicy?.some(policy))
                            }
                        }

                        Toggle("Force fallback mode", isOn: Binding(
                            get: { coordinator.rulesStore.rules[index].enableFallbackMode },
                            set: { coordinator.rulesStore.rules[index].enableFallbackMode = $0 }
                        ))
                    }
                    .padding(.vertical, 6)
                }
                .onDelete { offsets in
                    offsets.map { coordinator.rulesStore.rules[$0] }.forEach(coordinator.rulesStore.remove)
                }
            }
        }
        .padding(24)
    }

    private func addRule() {
        coordinator.rulesStore.upsert(
            UserRule(bundleIdentifier: newBundleIdentifier, appName: newAppName)
        )
        newBundleIdentifier = ""
        newAppName = ""
    }
}
