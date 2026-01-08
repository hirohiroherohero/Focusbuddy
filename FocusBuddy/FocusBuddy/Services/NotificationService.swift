import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {
        requestPermission()
    }

    // MARK: - Permission

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if granted {
                print("알림 권한 허용됨")
            }
        }
    }

    // MARK: - Notifications

    /// 집중 완료 → 휴식 시작 알림
    func notifyFocusComplete() {
        let content = UNMutableNotificationContent()
        content.title = "🎉 집중 완료!"
        content.body = "대단해! 25분 완전 정복! 이제 5분 휴식하자~"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil  // 즉시 발송
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 휴식 완료 → 다음 루프 시작 알림
    func notifyRestComplete(currentLoop: Int, targetLoop: Int) {
        let content = UNMutableNotificationContent()
        content.title = "💪 휴식 끝! (\(currentLoop)/\(targetLoop))"
        content.body = "다음 집중 시작! 화이팅!"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 모든 루프 완료 알림
    func notifyAllLoopsComplete(loops: Int) {
        let content = UNMutableNotificationContent()
        content.title = "🎊 \(loops)세트 완료!"
        content.body = "대단해! 오늘 목표 달성! 푹 쉬어~"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 포기 시 응원 알림
    func notifyGiveUp(message: String) {
        let content = UNMutableNotificationContent()
        content.title = "😊 괜찮아!"
        content.body = message
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }

    /// 칭호 획득 알림
    func notifyTitleUnlocked(title: Title) {
        let content = UNMutableNotificationContent()
        content.title = "\(title.icon) 새 칭호 획득!"
        content.body = "「\(title.name)」 칭호를 획득했어요! - \(title.description)"
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )

        UNUserNotificationCenter.current().add(request)
    }
}
