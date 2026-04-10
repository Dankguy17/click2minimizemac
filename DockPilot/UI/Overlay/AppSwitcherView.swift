import AppKit
import SwiftUI

struct AppSwitcherView: View {
    @ObservedObject var service: AppSwitcherService
    let onClose: () -> Void
    let onActivate: (AppDescriptor) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("DockPilot")
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(.secondary)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundStyle(.primary)
                        .frame(width: 26, height: 26)
                        .background(
                            Circle()
                                .fill(Color.white.opacity(0.16))
                        )
                }
                .buttonStyle(.plain)
                .contentShape(Circle())
                .help("Close App Switcher")
            }

            ForEach(Array(service.apps.enumerated()), id: \.element.id) { index, app in
                Button {
                    onActivate(app)
                } label: {
                    HStack(spacing: 12) {
                        AppIconView(bundleIdentifier: app.bundleIdentifier)
                            .frame(width: 26, height: 26)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(app.localizedName)
                                .font(.system(size: 15, weight: .semibold))
                            Text(app.bundleIdentifier)
                                .font(.system(size: 11, weight: .regular, design: .monospaced))
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                        Spacer()
                    }
                    .contentShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(index == service.selectedIndex ? Color.accentColor.opacity(0.2) : Color.clear)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .buttonStyle(.plain)
                .onHover { isHovering in
                    if isHovering {
                        service.select(app)
                    }
                }
            }
        }
        .padding(18)
        .frame(width: 360)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.18))
        )
        .shadow(color: Color.black.opacity(0.18), radius: 28, x: 0, y: 18)
    }
}

private struct AppIconView: View {
    let bundleIdentifier: String

    var body: some View {
        if let application = NSWorkspace.shared.runningApplications.first(where: { $0.bundleIdentifier == bundleIdentifier }),
           let icon = application.icon {
            Image(nsImage: icon)
                .resizable()
                .scaledToFit()
                .clipShape(RoundedRectangle(cornerRadius: 6))
        } else {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.gray.opacity(0.25))
        }
    }
}
