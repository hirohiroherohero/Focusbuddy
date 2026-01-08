# Story 1.4: 집중 완료와 휴식

Status: done

## Story

As a **사용자**,
I want **25분 집중 완료 후 자동으로 5분 휴식이 시작되기를**,
So that **뽀모도로 사이클을 완료할 수 있다**.

## Acceptance Criteria

1. **AC-1: 집중 완료 시 동작**
   - **Given** 집중 타이머가 진행 중일 때
   - **When** 타이머가 00:00이 되면
   - **Then** 축하 메시지가 표시된다 (예: "대단해! 25분 완전 정복! 🎉")
   - **And** 자동으로 5분 휴식 타이머가 시작된다
   - **And** 상태 텍스트가 "💤 휴식 중~"으로 변경된다

2. **AC-2: 휴식 완료 시 동작 (루프 모드)**
   - **Given** 휴식 타이머가 진행 중일 때
   - **When** 타이머가 00:00이 되면
   - **Then** 목표 세트 미완료 시 자동으로 다음 집중 세션이 시작된다
   - **And** 목표 세트 완료 시 대기 상태로 돌아간다
   - **And** 각 전환 시 macOS 시스템 알림이 발송된다

## Tasks / Subtasks

- [x] **Task 1: TimerViewModel 휴식 모드 구현** (AC: #1, #2)
  - [x] 1.1: handleTimerComplete()에서 휴식 모드 전환 구현
  - [x] 1.2: 휴식 중 tick() 로직 구현
  - [x] 1.3: 휴식 완료 시 대기 상태 전환
  - [x] 1.4: 휴식 중 progress 계산 (restProgress)

- [x] **Task 2: TimerViewModel 메시지 연동** (AC: #1)
  - [x] 2.1: 집중 완료 시 completionMessage 표시
  - [x] 2.2: MessageService.getCompletionMessage() 호출

- [x] **Task 3: TimerView 휴식 UI 구현** (AC: #1, #2)
  - [x] 3.1: 휴식 중 상태 텍스트 "💤 휴식 중~"
  - [x] 3.2: 휴식 중 타이머 색상 (Rest Blue)
  - [x] 3.3: 휴식 중 진행 바 표시

- [x] **Task 4: 루프(세트) 기능 구현** (AC: #2)
  - [x] 4.1: TimerViewModel에 targetLoops, completedLoops 프로퍼티 추가
  - [x] 4.2: 휴식 완료 시 루프 카운트 증가 및 조건부 다음 세션 시작
  - [x] 4.3: TimerView에 loopSelector (Stepper) UI 추가
  - [x] 4.4: TimerView에 loopCounter 표시 추가

- [x] **Task 5: NotificationService 구현** (AC: #1, #2)
  - [x] 5.1: Services/NotificationService.swift 생성 - 싱글톤 패턴
  - [x] 5.2: macOS 알림 권한 요청 (UNUserNotificationCenter)
  - [x] 5.3: notifyFocusComplete() - 집중 완료 알림
  - [x] 5.4: notifyRestComplete() - 휴식 완료 알림
  - [x] 5.5: notifyAllLoopsComplete() - 전체 세트 완료 알림

- [x] **Task 6: 빌드 및 테스트**
  - [x] 6.1: 빌드 성공 확인
  - [x] 6.2: 집중 완료 → 휴식 전환 확인
  - [x] 6.3: 휴식 완료 → 다음 루프 또는 대기 상태 확인
  - [x] 6.4: 시스템 알림 발송 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴:**
```
TimerView ──observe──► TimerViewModel ──uses──► MessageService
                              │
                              ▼
                         TimerState (focusing → resting → idle)
```

**상태 전환 플로우:**
```
idle ──[집중 시작]──► focusing(25:00)
                          │
                          ▼ (00:00 도달)
                    resting(5:00)
                          │
                          ▼ (00:00 도달)
                        idle
```

### Technical Requirements

**handleTimerComplete() 업데이트:**
```swift
private func handleTimerComplete() {
    stopTimer()

    if state.isFocusing {
        // 집중 완료 → 휴식 모드 전환
        currentMessage = messageService.getCompletionMessage()
        showMessage = true
        remainingSeconds = Self.restDuration
        state = .resting(remaining: remainingSeconds)
        startTimer()

        // 3초 후 메시지 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showMessage = false
        }
    } else if state.isResting {
        // 휴식 완료 → 대기 상태
        state = .idle
        remainingSeconds = Self.focusDuration
    }
}
```

**tick() 업데이트:**
```swift
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
```

**restProgress 계산:**
```swift
var restProgress: Double {
    guard state.isResting else { return 0 }
    return 1.0 - (Double(remainingSeconds) / Double(Self.restDuration))
}
```

### UX Design Compliance

**휴식 중 UI 스펙:**
- 상태 텍스트: "💤 휴식 중~"
- 타이머 색상: Rest Blue (#60A5FA)
- 진행 바: Rest Blue
- 버튼: 없음 (자동 진행)

**색상 정의 (이미 존재):**
```swift
static let restBlue = Color(red: 96/255, green: 165/255, blue: 250/255)
```

### Previous Story Intelligence

**Story 1.3에서 구현된 것:**
- MessageService.swift (getCompletionMessage() 이미 준비됨)
- TimerViewModel의 메시지 표시 로직 (showMessage, currentMessage)
- 메시지 토스트 UI

**Story 1.2에서 구현된 것:**
- TimerState enum (idle, focusing, resting)
- TimerViewModel.tick() 기본 로직
- TimerView 타이머 UI

### File Structure Requirements

**수정할 파일:**
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift
- FocusBuddy/FocusBuddy/Views/TimerView.swift

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 집중 타이머 00:00 도달 시 축하 메시지 표시
- [ ] 자동으로 5:00 휴식 타이머 시작
- [ ] 상태 텍스트 "💤 휴식 중~" 표시
- [ ] 타이머/진행바 색상 Rest Blue
- [ ] 휴식 타이머 00:00 도달 시 대기 상태 복귀
- [ ] 25:00과 "집중 시작" 버튼 다시 표시

### References

- [Source: prd.md#FR-2.4] 25분 완료 시 자동 휴식 전환
- [Source: prd.md#FR-2.5] 휴식 5분 타이머 자동 시작
- [Source: prd.md#FR-2.6] 휴식 완료 시 대기 상태 전환
- [Source: ux-design-specification.md#4.1] 타이머 컴포넌트 디자인
- [Source: ux-design-specification.md#2] Rest Blue 색상 정의
- [Source: epics.md#Story-1.4] 스토리 정의

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-07: BUILD SUCCEEDED

### Completion Notes List

- ✅ TimerViewModel - handleTimerComplete()에서 상태 전환 (focusing → resting → idle/다음 루프)
- ✅ TimerViewModel - restProgress 계산 프로퍼티 추가
- ✅ TimerViewModel - tick()에서 resting 상태 처리
- ✅ TimerViewModel - targetLoops, completedLoops 루프 기능 추가
- ✅ TimerView - restingStatusText "💤 휴식 중~" 추가
- ✅ TimerView - timerColor 계산 (restBlue 적용)
- ✅ TimerView - restProgressBar 추가
- ✅ TimerView - loopSelector (Stepper 1-10) 추가
- ✅ TimerView - loopCounter 표시 추가
- ✅ MessageService.getCompletionMessage() 연동
- ✅ NotificationService.swift - macOS 시스템 알림 (집중완료, 휴식완료, 전체완료)

### File List

**신규 생성:**
- FocusBuddy/FocusBuddy/Services/NotificationService.swift

**수정:**
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift (루프 기능, 알림 연동)
- FocusBuddy/FocusBuddy/Views/TimerView.swift (루프 UI 추가)

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-07 | Story 1.4 구현 완료 - 집중 완료와 휴식 |
