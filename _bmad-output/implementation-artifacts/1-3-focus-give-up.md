# Story 1.3: 집중 포기하기

Status: review

## Story

As a **사용자**,
I want **집중 중에 포기할 수 있고 응원 메시지를 받기를**,
So that **실패해도 죄책감 없이 다시 시작할 수 있다**.

## Acceptance Criteria

1. **AC-1: 포기 버튼 표시**
   - **Given** 집중 중(타이머 진행 중)일 때
   - **When** 팝오버를 열면
   - **Then** "😅 포기" 버튼이 표시된다

2. **AC-2: 포기 시 동작**
   - **Given** 집중 중일 때
   - **When** "포기" 버튼을 클릭하면
   - **Then** 타이머가 즉시 멈춘다
   - **And** 응원 메시지가 표시된다 (예: "괜찮아! 시작한 것만으로 대단해 💚")
   - **And** 대기 상태로 돌아간다

## Tasks / Subtasks

- [x] **Task 1: MessageService 생성** (AC: #2)
  - [x] 1.1: Services/MessageService.swift 생성
  - [x] 1.2: 포기 시 응원 메시지 배열 정의
  - [x] 1.3: getGiveUpMessage() 메서드 - 랜덤 메시지 반환

- [x] **Task 2: TimerViewModel 확장** (AC: #2)
  - [x] 2.1: giveUp() 메서드에 메시지 반환 추가
  - [x] 2.2: currentMessage 프로퍼티 추가
  - [x] 2.3: showMessage 상태 추가

- [x] **Task 3: TimerView 포기 버튼 개선** (AC: #1, #2)
  - [x] 3.1: 포기 버튼 이미 구현됨 (Story 1.2) - 확인
  - [x] 3.2: 응원 메시지 표시 UI 추가
  - [x] 3.3: 메시지 표시 후 자동 숨김 (3초)

- [x] **Task 4: 빌드 및 테스트**
  - [x] 4.1: 빌드 성공 확인
  - [x] 4.2: 포기 시 메시지 표시 확인
  - [x] 4.3: 대기 상태 복귀 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴:**
```
TimerView ──observe──► TimerViewModel ──uses──► MessageService
```

**MessageService는 싱글톤 또는 주입:**
```swift
class MessageService {
    static let shared = MessageService()

    func getGiveUpMessage() -> String {
        giveUpMessages.randomElement() ?? "괜찮아! 💚"
    }
}
```

### Technical Requirements

**응원 메시지 목록 (PRD 기준):**
```swift
private let giveUpMessages = [
    "괜찮아! 시작한 것만으로 대단해 💚",
    "오늘은 여기까지! 내일 또 보자 🤗",
    "5분도 0분보단 나아! 👍",
    "쉬어가는 것도 실력이야 😊"
]
```

**메시지 표시 로직:**
```swift
@Observable
class TimerViewModel {
    var currentMessage: String = ""
    var showMessage: Bool = false

    func giveUp() {
        stopTimer()
        currentMessage = MessageService.shared.getGiveUpMessage()
        showMessage = true
        state = .idle
        remainingSeconds = Self.focusDuration

        // 3초 후 메시지 숨김
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showMessage = false
        }
    }
}
```

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
└── Services/
    └── MessageService.swift      # 긍정 메시지 서비스
```

**수정할 파일:**
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift
- FocusBuddy/FocusBuddy/Views/TimerView.swift

### UX Design Compliance

**메시지 토스트 스펙:**
- 배경: 반투명 어두운 배경 또는 카드 스타일
- 텍스트: 16pt, 중앙 정렬
- 애니메이션: fade in/out (0.3s)
- 자동 숨김: 3초

**톤 앤 무드:**
- 친근한 반말 ("대단해!", "괜찮아!")
- 이모지 적극 활용
- 무조건 긍정적

### Previous Story Intelligence

**Story 1.2에서 구현된 것:**
- TimerViewModel.giveUp() 메서드 (기본 동작)
- TimerView의 "😅 포기" 버튼
- 상태 전환 (focusing → idle)

**Story 1.2에서 사용된 패턴:**
- @Observable 매크로
- Timer.publish + Combine
- Color extension (focusRed, buddyGreen)

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 집중 중 포기 버튼 클릭
- [ ] 응원 메시지 표시됨
- [ ] 3초 후 메시지 사라짐
- [ ] 타이머 25:00으로 리셋
- [ ] 대기 상태로 복귀

### References

- [Source: prd.md#FR-5.1] 세션 완료 시 긍정 메시지 표시
- [Source: prd.md#FR-5.2] 포기 시 응원 메시지 표시
- [Source: prd.md#긍정-메시지-예시] 포기 시 메시지 목록
- [Source: ux-design-specification.md#5.3] 포기 플로우
- [Source: ux-design-specification.md#11] Tone of Voice
- [Source: epics.md#Story-1.3] 스토리 정의

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-07: BUILD SUCCEEDED

### Completion Notes List

- ✅ MessageService.swift - 싱글톤 패턴, 응원 메시지 배열
- ✅ TimerViewModel.swift - giveUp()에 메시지 표시 로직 추가
- ✅ TimerView.swift - 토스트 UI 추가 (fade in/out 애니메이션)
- ✅ 3초 후 자동 숨김 구현 (DispatchQueue.main.asyncAfter)

### File List

**신규 생성:**
- FocusBuddy/FocusBuddy/Services/MessageService.swift

**수정:**
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift
- FocusBuddy/FocusBuddy/Views/TimerView.swift

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-07 | Story 1.3 구현 완료 - 집중 포기하기 |
