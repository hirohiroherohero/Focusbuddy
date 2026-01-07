import Foundation
import Combine
import SwiftUI

@Observable
class TimerViewModel {
    // MARK: - Singleton

    static let shared = TimerViewModel()

    // MARK: - Properties

    private(set) var state: TimerState = .idle
    private(set) var remainingSeconds: Int = 25 * 60

    // 메시지 관련
    var currentMessage: String = ""
    var showMessage: Bool = false

    private var timerCancellable: AnyCancellable?
    private let messageService = MessageService.shared
    private let sessionRepository = SessionRepository.shared
    private let notificationService = NotificationService.shared
    private var sessionStartTime: Date?

    /// 루프 설정
    var targetLoops: Int = 4           // 목표 루프 횟수 (기본 4회 = 뽀모도로 1세트)
    private(set) var completedLoops: Int = 0  // 완료한 루프 횟수

    // MARK: - Constants

    static let focusDuration: Int = 25 * 60  // 25분
    static let restDuration: Int = 5 * 60    // 5분

    // MARK: - Computed Properties

    var displayTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard state.isFocusing else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(Self.focusDuration))
    }

    var restProgress: Double {
        guard state.isResting else { return 0 }
        return 1.0 - (Double(remainingSeconds) / Double(Self.restDuration))
    }

    /// 루프 상태 표시 (예: "2/4")
    var loopStatus: String {
        "\(completedLoops)/\(targetLoops)"
    }

    // MARK: - Actions

    func startFocus() {
        // 대기 상태에서 시작하면 루프 카운트 리셋
        if state == .idle {
            completedLoops = 0
        }
        sessionStartTime = Date()
        remainingSeconds = Self.focusDuration
        state = .focusing(remaining: remainingSeconds)
        startTimer()
    }

    func giveUp() {
        stopTimer()
        currentMessage = messageService.getGiveUpMessage()
        withAnimation(.easeInOut(duration: 0.3)) {
            showMessage = true
        }
        state = .idle
        remainingSeconds = Self.focusDuration

        // 3초 후 메시지 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            withAnimation(.easeInOut(duration: 0.3)) {
                self?.showMessage = false
            }
        }
    }

    // MARK: - Private Methods

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            handleTimerComplete()
            return
        }
        remainingSeconds -= 1

        if state.isFocusing {
            state = .focusing(remaining: remainingSeconds)
        } else if state.isResting {
            state = .resting(remaining: remainingSeconds)
        }
    }

    private func handleTimerComplete() {
        stopTimer()

        if state.isFocusing {
            // 세션 저장
            if let startTime = sessionStartTime {
                let session = SessionRecord(
                    startTime: startTime,
                    endTime: Date(),
                    completed: true
                )
                sessionRepository.save(session)
            }

            // macOS 알림 발송
            notificationService.notifyFocusComplete()

            // 집중 완료 → 휴식 모드 전환
            currentMessage = messageService.getCompletionMessage()
            withAnimation(.easeInOut(duration: 0.3)) {
                showMessage = true
            }
            remainingSeconds = Self.restDuration
            state = .resting(remaining: remainingSeconds)
            startTimer()

            // 3초 후 메시지 숨김
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
                withAnimation(.easeInOut(duration: 0.3)) {
                    self?.showMessage = false
                }
            }
        } else if state.isResting {
            // 루프 카운트 증가
            completedLoops += 1

            // 목표 달성 확인
            if completedLoops >= targetLoops {
                // 모든 루프 완료!
                notificationService.notifyAllLoopsComplete(loops: completedLoops)
                state = .idle
                remainingSeconds = Self.focusDuration
            } else {
                // 다음 루프 시작
                notificationService.notifyRestComplete(currentLoop: completedLoops, targetLoop: targetLoops)
                startFocus()
            }
        }
    }
}
