import Foundation

final class TitleChecker {
    static let shared = TitleChecker()

    private let titleRepository = TitleRepository.shared
    private let sessionRepository = SessionRepository.shared
    private let notificationService = NotificationService.shared

    private init() {}

    // MARK: - Public Methods

    /// 모든 칭호 조건을 평가하고 달성 시 잠금해제
    func checkAndUnlockTitles() {
        for title in Title.allTitles {
            guard !titleRepository.isUnlocked(title.id) else { continue }
            if evaluateCondition(title.condition) {
                titleRepository.unlock(title.id)
                // macOS 시스템 알림
                notificationService.notifyTitleUnlocked(title: title)

                // 인앱 팝업 트리거
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .titleUnlocked,
                        object: title
                    )
                }
            }
        }
    }

    // MARK: - Private Methods

    private func evaluateCondition(_ condition: TitleCondition) -> Bool {
        switch condition {
        case .sessionCount(let n):
            return completedSessionCount >= n

        case .streakDays(let n):
            return calculateStreak() >= n

        case .afterGiveUp:
            return sessionRepository.hasGivenUp && completedSessionCount > 0

        case .timeOfDay(let hour, let before):
            let currentHour = Calendar.current.component(.hour, from: Date())
            return before ? currentHour < hour : currentHour >= hour

        case .dayOfWeek(let days):
            let weekday = Calendar.current.component(.weekday, from: Date())
            return days.contains(weekday)

        case .totalDays(let n):
            return uniqueFocusDays >= n
        }
    }

    private var completedSessionCount: Int {
        sessionRepository.sessions.filter { $0.completed }.count
    }

    private var uniqueFocusDays: Int {
        Set(sessionRepository.sessions
            .filter { $0.completed }
            .map { Calendar.current.startOfDay(for: $0.startTime) }
        ).count
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        var dayCounts: [Date: Int] = [:]
        for session in sessionRepository.sessions where session.completed {
            let day = calendar.startOfDay(for: session.startTime)
            dayCounts[day, default: 0] += 1
        }

        var checkDate = today
        if dayCounts[today] == nil || dayCounts[today] == 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
                return 0
            }
            checkDate = yesterday
        }

        var streak = 0
        while let count = dayCounts[checkDate], count > 0 {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = prev
        }

        return streak
    }
}
