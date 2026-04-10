import SwiftUI

struct DiagnosticsView: View {
    @ObservedObject var coordinator: AppCoordinator

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                GroupBox("Status") {
                    Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
                        statusRow("Accessibility", coordinator.diagnosticsService.snapshot.accessibilityTrusted ? "Granted" : "Missing")
                        statusRow("Event Tap", coordinator.diagnosticsService.snapshot.eventTapEnabled ? "Enabled" : "Disabled")
                        statusRow("Frontmost App", coordinator.diagnosticsService.snapshot.frontmostAppName)
                        statusRow("Bundle ID", coordinator.diagnosticsService.snapshot.frontmostBundleIdentifier)
                        statusRow("Resolved State", coordinator.diagnosticsService.snapshot.resolvedState.rawValue)
                        statusRow("Window Count", "\(coordinator.diagnosticsService.snapshot.windowCount)")
                        statusRow("Planned Action", coordinator.diagnosticsService.snapshot.plannedAction)
                        statusRow("Executed Action", coordinator.diagnosticsService.snapshot.executedAction)
                        statusRow("Fallback Used", coordinator.diagnosticsService.snapshot.fallbackUsed ? "Yes" : "No")
                        statusRow("Last Input Event", coordinator.diagnosticsService.snapshot.lastInputEvent)
                        statusRow("Last Error", coordinator.diagnosticsService.snapshot.lastError)
                    }
                }

                GroupBox("Recent Action Results") {
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(coordinator.diagnosticsService.recentResults) { result in
                            HStack {
                                Text(result.action.label)
                                Spacer()
                                Text(result.status.rawValue)
                                    .foregroundStyle(result.status == .failure ? .red : .secondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                GroupBox("Event Trace") {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(coordinator.eventTraceStore.entries.prefix(25)) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(entry.category.rawValue.uppercased())
                                        .font(.caption.weight(.semibold))
                                        .foregroundStyle(.secondary)
                                    Spacer()
                                    Text(entry.timestamp.formatted(date: .omitted, time: .standard))
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Text(entry.message)
                                if !entry.metadata.isEmpty {
                                    Text(entry.metadata.map { "\($0.key)=\($0.value)" }.joined(separator: " "))
                                        .font(.caption.monospaced())
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    @ViewBuilder
    private func statusRow(_ title: String, _ value: String) -> some View {
        GridRow {
            Text(title)
                .foregroundStyle(.secondary)
            Text(value)
        }
    }
}
