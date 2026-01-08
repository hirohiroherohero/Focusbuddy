import Foundation

@Observable
class CalendarViewModel {
    private let sessionRepository = SessionRepository.shared

    var daySessionCounts: [Date: Int] = [:]
    var calendarWeeks: [[Date]] = []  // 52주 x 7일
    var streak: Int = 0
    var totalFocusMinutes: Int = 0

    init() {
        generateCalendarDays()
        calculateDaySessionCounts()
        streak = calculateStreak()
        totalFocusMinutes = calculateTotalFocusTime()
    }

    // MARK: - Public Methods

    func loadData() {
        calculateDaySessionCounts()
        streak = calculateStreak()
        totalFocusMinutes = calculateTotalFocusTime()
    }

    func sessionCount(for date: Date) -> Int {
        let day = Calendar.current.startOfDay(for: date)
        return daySessionCounts[day] ?? 0
    }

    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    var flattenedDays: [Date] {
        calendarWeeks.flatMap { $0 }
    }

    // MARK: - Private Methods

    private func generateCalendarDays() {
        var weeks: [[Date]] = []
        let calendar = Calendar.current
        let today = Date()

        // 오늘이 포함된 주의 토요일 찾기 (일요일 시작 기준)
        let weekday = calendar.component(.weekday, from: today)
        let daysToSaturday = 7 - weekday
        guard let endOfWeek = calendar.date(byAdding: .day, value: daysToSaturday, to: today) else { return }

        // 52주 전 일요일로 이동
        guard var currentDate = calendar.date(byAdding: .weekOfYear, value: -51, to: endOfWeek) else { return }

        // 해당 주의 일요일로 이동
        let currentWeekday = calendar.component(.weekday, from: currentDate)
        let daysToSubtract = currentWeekday - 1
        currentDate = calendar.date(byAdding: .day, value: -daysToSubtract, to: currentDate) ?? currentDate

        // 52주 생성
        for _ in 0..<52 {
            var week: [Date] = []
            for _ in 0..<7 {
                week.append(currentDate)
                currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate) ?? currentDate
            }
            weeks.append(week)
        }

        calendarWeeks = weeks
    }

    private func calculateDaySessionCounts() {
        let sessions = sessionRepository.sessions
        var counts: [Date: Int] = [:]

        for session in sessions where session.completed {
            let day = Calendar.current.startOfDay(for: session.startTime)
            counts[day, default: 0] += 1
        }

        daySessionCounts = counts
    }

    private func calculateStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 오늘 또는 어제부터 시작 (오늘 아직 집중 안했으면 어제부터)
        var checkDate = today
        if daySessionCounts[today] == nil || daySessionCounts[today] == 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else {
                return 0
            }
            checkDate = yesterday
        }

        var streakCount = 0
        while let count = daySessionCounts[checkDate], count > 0 {
            streakCount += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
                break
            }
            checkDate = previousDay
        }

        return streakCount
    }

    private func calculateTotalFocusTime() -> Int {
        let sessions = sessionRepository.sessions
        let totalMinutes = sessions
            .filter { $0.completed }
            .reduce(0) { $0 + $1.durationMinutes }
        return totalMinutes
    }
}
