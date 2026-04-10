import SwiftUI

struct GesturesSettingsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                GroupBox("Gesture Toggles") {
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Enable title bar gestures", isOn: binding(\.gestures.enableTitleBarGestures))
                        Toggle("Enable notch trigger behavior", isOn: binding(\.gestures.enableNotchTrigger))
                        Toggle("Enable scroll gestures", isOn: binding(\.gestures.enableScrollGestures))
                        Toggle("Enable rocker gestures", isOn: binding(\.gestures.enableRockerGestures))
                        Toggle("Enable trackpad modifier gestures", isOn: binding(\.gestures.enableTrackpadModifierGestures))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Mapped Gestures") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(Array(coordinator.settingsStore.settings.gestureDefinitions.enumerated()), id: \.element.id) { index, gesture in
                            HStack {
                                Toggle(gesture.name, isOn: Binding(
                                    get: { coordinator.settingsStore.settings.gestureDefinitions[index].isEnabled },
                                    set: { coordinator.settingsStore.settings.gestureDefinitions[index].isEnabled = $0 }
                                ))
                                Spacer()
                                Picker(
                                    "",
                                    selection: Binding(
                                        get: { coordinator.settingsStore.settings.gestureDefinitions[index].action },
                                        set: { coordinator.settingsStore.settings.gestureDefinitions[index].action = $0 }
                                    )
                                ) {
                                    ForEach(ActionType.allCases) { action in
                                        Text(action.label).tag(action)
                                    }
                                }
                                .frame(width: 220)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private func binding<Value>(_ keyPath: WritableKeyPath<DockPilotSettings, Value>) -> Binding<Value> {
        Binding(
            get: { coordinator.settingsStore.settings[keyPath: keyPath] },
            set: { coordinator.settingsStore.settings[keyPath: keyPath] = $0 }
        )
    }
}
