import SwiftUI

private enum SettingsSection: String, CaseIterable, Identifiable {
    case general
    case gestures
    case rules
    case diagnostics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general:
            return "General"
        case .gestures:
            return "Gestures"
        case .rules:
            return "Per-App Rules"
        case .diagnostics:
            return "Diagnostics"
        }
    }
}

struct SettingsRootView: View {
    @ObservedObject var coordinator: AppCoordinator
    @State private var selection: SettingsSection = .general

    var body: some View {
        NavigationSplitView {
            List(SettingsSection.allCases, selection: $selection) { section in
                Text(section.title)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            switch selection {
            case .general:
                GeneralSettingsView(coordinator: coordinator)
            case .gestures:
                GesturesSettingsView(coordinator: coordinator)
            case .rules:
                RulesSettingsView(coordinator: coordinator)
            case .diagnostics:
                DiagnosticsView(coordinator: coordinator)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
