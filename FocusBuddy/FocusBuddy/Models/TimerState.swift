import Foundation

enum TimerState: Equatable {
    case idle
    case focusing(remaining: Int)
    case resting(remaining: Int)

    var isFocusing: Bool {
        if case .focusing = self { return true }
        return false
    }

    var isResting: Bool {
        if case .resting = self { return true }
        return false
    }

    var isRunning: Bool {
        isFocusing || isResting
    }
}
