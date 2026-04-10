import AppKit
import Foundation

struct FallbackActionExecutor: FallbackExecuting {
    private let appleScriptExecutor: AppleScriptExecutor

    init(appleScriptExecutor: AppleScriptExecutor) {
        self.appleScriptExecutor = appleScriptExecutor
    }

    func perform(plan: ActionPlan, for application: NSRunningApplication) -> ExecutionResult? {
        guard let bundleIdentifier = application.bundleIdentifier else {
            return nil
        }

        let finalAction = plan.steps.last?.action ?? .noOp
        let success: Bool
        switch finalAction {
        case .activateApp, .unhideApp, .restoreAllWindows, .restoreLastFocusedWindow:
            success = appleScriptExecutor.activate(bundleIdentifier: bundleIdentifier)
        case .hideApp, .minimizeAllWindows, .minimizeFrontWindow:
            success = appleScriptExecutor.hide(bundleIdentifier: bundleIdentifier)
        default:
            success = appleScriptExecutor.activate(bundleIdentifier: bundleIdentifier)
        }

        return ExecutionResult(
            action: finalAction,
            status: success ? .success : .failure,
            usedFallback: true,
            message: success ? "AppleScript fallback succeeded" : "AppleScript fallback failed"
        )
    }
}
