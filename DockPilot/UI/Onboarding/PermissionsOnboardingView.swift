import SwiftUI

struct PermissionsOnboardingView: View {
    let accessibilityGranted: Bool
    let eventTapGranted: Bool
    let onRequestPermissions: () -> Void
    let onContinue: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text("DockPilot Permissions")
                .font(.title2.weight(.semibold))
            Text("DockPilot relies on Accessibility permission and a session event tap to inspect app windows and react to title bar or Dock gestures.")
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 10) {
                permissionRow(title: "Accessibility", granted: accessibilityGranted)
                permissionRow(title: "Input Monitoring / Event Tap", granted: eventTapGranted)
            }

            HStack {
                Button("Open System Prompt") {
                    onRequestPermissions()
                }
                Button("Continue") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.top, 8)
        }
        .padding(24)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func permissionRow(title: String, granted: Bool) -> some View {
        HStack {
            Circle()
                .fill(granted ? Color.green : Color.orange)
                .frame(width: 10, height: 10)
            Text(title)
            Spacer()
            Text(granted ? "Granted" : "Needs Attention")
                .foregroundStyle(.secondary)
        }
    }
}
