import AppKit
import Foundation

protocol RunningAppsProviding {
    func runningApplications() -> [AppDescriptor]
    func application(for bundleIdentifier: String) -> NSRunningApplication?
}

struct RunningAppsService: RunningAppsProviding {
    func runningApplications() -> [AppDescriptor] {
        NSWorkspace.shared.runningApplications
            .filter { $0.bundleIdentifier != Bundle.main.bundleIdentifier }
            .filter { $0.activationPolicy == .regular || $0.bundleIdentifier == "com.apple.finder" }
            .sorted { lhs, rhs in
                lhs.localizedName ?? lhs.bundleIdentifier ?? "" < rhs.localizedName ?? rhs.bundleIdentifier ?? ""
            }
            .map(AppDescriptor.init)
    }

    func application(for bundleIdentifier: String) -> NSRunningApplication? {
        NSWorkspace.shared.runningApplications.first { $0.bundleIdentifier == bundleIdentifier }
    }
}

extension AppDescriptor {
    init(_ application: NSRunningApplication) {
        self.init(
            bundleIdentifier: application.bundleIdentifier ?? "unknown.bundle",
            localizedName: application.localizedName ?? "Unknown App",
            processIdentifier: application.processIdentifier,
            isHidden: application.isHidden,
            isFrontmost: application.isActive,
            activationPolicy: {
                switch application.activationPolicy {
                case .regular:
                    return "regular"
                case .accessory:
                    return "accessory"
                case .prohibited:
                    return "prohibited"
                @unknown default:
                    return "unknown"
                }
            }(),
            launchDate: application.launchDate
        )
    }
}
