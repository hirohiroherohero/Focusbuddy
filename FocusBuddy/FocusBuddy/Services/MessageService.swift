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

    // MARK: - 세션 완료 메시지 (Story 1.4에서 사용)

    private let completionMessages = [
        "대단해! 25분 완전 정복! 🎉",
        "역시 넌 할 수 있어! 💪",
        "오늘도 성장했어! 🌱",
        "집중력 레벨업! ⬆️",
        "멋져! 한 세션 완료! ✨"
    ]

    func getCompletionMessage() -> String {
        completionMessages.randomElement() ?? "잘했어! 🎉"
    }

    // MARK: - 재시작 환영 메시지 (Story 4.2에서 사용)

    private let welcomeBackMessages = [
        "다시 와줬네! 반가워 🙌",
        "또 도전하는 너, 멋져! ✨",
        "포기 안 하는 게 진짜 실력이야 💪"
    ]

    func getWelcomeBackMessage() -> String {
        welcomeBackMessages.randomElement() ?? "반가워! 🙌"
    }
}
