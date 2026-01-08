import Foundation

final class MessageService {
    static let shared = MessageService()

    private init() {}

    // MARK: - 포기 시 응원 메시지

    private let giveUpMessages = [
        "괜찮아! 시작한 것만으로 대단해 💚",
        "오늘은 여기까지! 내일 또 보자 🤗",
        "5분도 0분보단 나아! 👍",
        "쉬어가는 것도 실력이야 😊",
        "다음엔 더 잘할 수 있어! 💪",
        "포기해도 괜찮아, 다시 시작하면 돼 🌱"
    ]

    func getGiveUpMessage() -> String {
        giveUpMessages.randomElement() ?? "괜찮아! 💚"
    }

    // MARK: - 세션 완료 메시지

    private let completionMessages = [
        "대단해! 25분 완전 정복! 🎉",
        "역시 넌 할 수 있어! 💪",
        "오늘도 성장했어! 🌱",
        "집중력 레벨업! ⬆️",
        "멋져! 한 세션 완료! ✨"
    ]

    // MARK: - 첫 완료 메시지

    private let firstCompletionMessages = [
        "첫 세션 완료! 시작이 반이야! 🎊",
        "드디어 첫 집중 성공! 대단해! 🌟",
        "첫 발을 내딛었어! 앞으로가 기대돼! 🚀"
    ]

    // MARK: - 스트릭 메시지

    private let streakMessages: [Int: [String]] = [
        3: [
            "3일 연속! 습관이 만들어지고 있어! 🔥",
            "벌써 3일째! 꾸준함이 빛나! ✨"
        ],
        7: [
            "일주일 연속 집중! 정말 대단해! 🏆",
            "7일 스트릭 달성! 넌 진짜야! 💎"
        ],
        14: [
            "2주 연속! 이제 집중이 습관이 됐어! 🌈",
            "14일 스트릭! 멈출 수 없어! 🚀"
        ],
        30: [
            "한 달 연속! 전설이 되어가고 있어! 👑",
            "30일 스트릭! 넌 집중의 달인! 🏅"
        ]
    ]

    // MARK: - 재시작 환영 메시지 (포기 후 재도전)

    private let welcomeBackMessages = [
        "다시 와줬네! 반가워 🙌",
        "또 도전하는 너, 멋져! ✨",
        "포기 안 하는 게 진짜 실력이야 💪"
    ]

    func getWelcomeBackMessage() -> String {
        welcomeBackMessages.randomElement() ?? "반가워! 🙌"
    }

    // MARK: - 상황별 완료 메시지 (FR-5.4)

    func getCompletionMessage(sessionCount: Int = 0, streakDays: Int = 0) -> String {
        // 첫 완료
        if sessionCount == 1 {
            return firstCompletionMessages.randomElement() ?? "첫 세션 완료! 🎊"
        }

        // 스트릭 기념 (정확히 해당 일수일 때만)
        if let messages = streakMessages[streakDays] {
            return messages.randomElement() ?? completionMessages.randomElement() ?? "잘했어! 🎉"
        }

        // 일반 완료
        return completionMessages.randomElement() ?? "잘했어! 🎉"
    }
}
