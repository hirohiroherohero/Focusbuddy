import Foundation

struct Title: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let condition: TitleCondition
    var unlockedAt: Date?

    var isUnlocked: Bool { unlockedAt != nil }
}

// MARK: - TitleCondition

enum TitleCondition: Codable, Equatable {
    case sessionCount(Int)              // N회 세션 완료
    case streakDays(Int)                // N일 연속
    case timeOfDay(hour: Int, before: Bool)  // 특정 시간 (before: true = 이전, false = 이후)
    case dayOfWeek([Int])               // 특정 요일 (1=일, 7=토)
    case totalDays(Int)                 // 총 사용일
    case afterGiveUp                    // 포기 후 재도전
}

// MARK: - Static Data (10 MVP Titles)

extension Title {
    static let allTitles: [Title] = [
        Title(
            id: "first_focus",
            name: "신입 집중러",
            icon: "🌱",
            description: "첫 세션 완료",
            condition: .sessionCount(1)
        ),
        Title(
            id: "never_give_up",
            name: "포기하지 않는 자",
            icon: "💪",
            description: "포기 후 다시 완료",
            condition: .afterGiveUp
        ),
        Title(
            id: "streak_7",
            name: "꾸준함의 시작",
            icon: "🔥",
            description: "7일 연속",
            condition: .streakDays(7)
        ),
        Title(
            id: "sessions_10",
            name: "진짜 집중러",
            icon: "🏅",
            description: "10회 세션 완료",
            condition: .sessionCount(10)
        ),
        Title(
            id: "early_bird",
            name: "아침형 인간",
            icon: "🌅",
            description: "오전 9시 이전 완료",
            condition: .timeOfDay(hour: 9, before: true)
        ),
        Title(
            id: "night_owl",
            name: "올빼미",
            icon: "🦉",
            description: "자정 이후 완료",
            condition: .timeOfDay(hour: 0, before: false)
        ),
        Title(
            id: "weekend_warrior",
            name: "주말 전사",
            icon: "⚔️",
            description: "토/일요일 완료",
            condition: .dayOfWeek([1, 7])
        ),
        Title(
            id: "streak_30",
            name: "한 달의 기적",
            icon: "✨",
            description: "30일 연속",
            condition: .streakDays(30)
        ),
        Title(
            id: "sessions_50",
            name: "집중 마스터",
            icon: "👑",
            description: "50회 세션 완료",
            condition: .sessionCount(50)
        ),
        Title(
            id: "days_100",
            name: "100일의 기록",
            icon: "📜",
            description: "100일 사용",
            condition: .totalDays(100)
        ),
    ]
}
