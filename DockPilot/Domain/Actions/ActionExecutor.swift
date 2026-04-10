import AppKit
import Foundation

protocol WindowActing {
    func execute(plan: ActionPlan, for application: NSRunningApplication, windowState: AppState?) -> ExecutionResult
}

protocol AppWindowMutating {
    func activate(_ application: NSRunningApplication) -> Bool
    func unhide(_ application: NSRunningApplication) -> Bool
    func hide(_ application: NSRunningApplication) -> Bool
    func bringAllToFront(_ application: NSRunningApplication) -> Bool
    func minimizeWindows(of application: NSRunningApplication, matching ids: [String]) -> Bool
    func restoreWindows(of application: NSRunningApplication, matching ids: [String]) -> Bool
    func toggleFullscreen(of application: NSRunningApplication, matching ids: [String]) -> Bool
    func snapLeft(of application: NSRunningApplication, matching ids: [String]) -> Bool
    func snapRight(of application: NSRunningApplication, matching ids: [String]) -> Bool
    func fill(of application: NSRunningApplication, matching ids: [String]) -> Bool
    func restoreFrame(of application: NSRunningApplication, matching ids: [String]) -> Bool
}

protocol FallbackExecuting {
    func perform(plan: ActionPlan, for application: NSRunningApplication) -> ExecutionResult?
}

struct ActionExecutor: WindowActing {
    private let mutator: AppWindowMutating
    private let fallbackExecutor: FallbackExecuting?

    init(mutator: AppWindowMutating, fallbackExecutor: FallbackExecuting?) {
        self.mutator = mutator
        self.fallbackExecutor = fallbackExecutor
    }

    func execute(plan: ActionPlan, for application: NSRunningApplication, windowState: AppState?) -> ExecutionResult {
        for step in plan.steps {
            let success = execute(step: step, application: application)
            if !success {
                if plan.requiresFallback, let fallbackResult = fallbackExecutor?.perform(plan: plan, for: application) {
                    return fallbackResult
                }

                return ExecutionResult(
                    action: step.action,
                    status: step.action == .noOp ? .noOp : .failure,
                    usedFallback: false,
                    message: "Failed while executing \(step.action.label)"
                )
            }
        }

        let finalAction = plan.steps.last?.action ?? .noOp
        return ExecutionResult(
            action: finalAction,
            status: finalAction == .noOp ? .noOp : .success,
            usedFallback: false,
            message: plan.reason
        )
    }

    private func execute(step: ActionPlan.Step, application: NSRunningApplication) -> Bool {
        switch step.action {
        case .dockSemanticToggle:
            return false
        case .activateApp:
            return mutator.activate(application)
        case .unhideApp:
            return mutator.unhide(application)
        case .restoreAllWindows, .restoreLastFocusedWindow:
            return mutator.restoreWindows(of: application, matching: step.targetWindowIDs)
        case .minimizeAllWindows, .minimizeFrontWindow:
            return mutator.minimizeWindows(of: application, matching: step.targetWindowIDs)
        case .hideApp:
            return mutator.hide(application)
        case .bringAllToFront:
            return mutator.bringAllToFront(application)
        case .toggleFullscreen:
            return mutator.toggleFullscreen(of: application, matching: step.targetWindowIDs)
        case .snapLeft:
            return mutator.snapLeft(of: application, matching: step.targetWindowIDs)
        case .snapRight:
            return mutator.snapRight(of: application, matching: step.targetWindowIDs)
        case .fill:
            return mutator.fill(of: application, matching: step.targetWindowIDs)
        case .restoreFrame:
            return mutator.restoreFrame(of: application, matching: step.targetWindowIDs)
        case .showSwitcherOverlay, .cycleRecentApps:
            return true
        case .noOp:
            return true
        }
    }
}
