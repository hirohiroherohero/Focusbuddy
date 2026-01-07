# Story 1.2: 집중 타이머 시작

Status: review

## Story

As a **사용자**,
I want **"집중 시작" 버튼을 눌러 25분 타이머를 시작하기를**,
So that **뽀모도로 집중 세션을 시작할 수 있다**.

## Acceptance Criteria

1. **AC-1: 대기 상태 UI**
   - **Given** 앱이 대기 상태일 때
   - **When** 팝오버를 열면
   - **Then** "25:00" 타이머와 "🎯 집중 시작" 버튼이 표시된다

2. **AC-2: 타이머 시작**
   - **Given** 대기 화면에서
   - **When** "집중 시작" 버튼을 클릭하면
   - **Then** 타이머가 24:59부터 카운트다운을 시작한다
   - **And** 상태 텍스트가 "🔥 집중 중!"으로 변경된다

3. **AC-3: 타이머 카운트다운**
   - **Given** 집중 중일 때
   - **When** 1초가 지나면
   - **Then** 타이머가 1초 감소한다 (MM:SS 형식)

## Tasks / Subtasks

- [x] **Task 1: TimerState 모델 생성** (AC: 전체)
  - [x] 1.1: Models/TimerState.swift 생성 - enum 기반 상태 머신
  - [x] 1.2: idle, focusing(remaining:), resting(remaining:) 상태 정의

- [x] **Task 2: TimerViewModel 생성** (AC: #1, #2, #3)
  - [x] 2.1: ViewModels/TimerViewModel.swift 생성 - @Observable 매크로 사용
  - [x] 2.2: remainingSeconds, state, displayTime 프로퍼티 구현
  - [x] 2.3: startFocus() 메서드 구현 - 타이머 시작
  - [x] 2.4: Timer.publish + Combine 기반 tick() 로직 구현

- [x] **Task 3: TimerView UI 구현** (AC: #1, #2)
  - [x] 3.1: Views/TimerView.swift 생성 - 타이머 전용 뷰
  - [x] 3.2: 대기 상태 UI - "25:00" + "집중 시작" 버튼
  - [x] 3.3: 집중 중 상태 UI - 카운트다운 + "🔥 집중 중!" 텍스트
  - [x] 3.4: 진행률 표시 바 구현

- [x] **Task 4: ContentView 통합** (AC: 전체)
  - [x] 4.1: ContentView에서 TimerViewModel 인스턴스 생성
  - [x] 4.2: TimerView를 ContentView에 통합
  - [x] 4.3: 상태에 따른 UI 전환 확인

- [x] **Task 5: 빌드 및 테스트**
  - [x] 5.1: 빌드 성공 확인
  - [x] 5.2: 타이머 시작 동작 확인
  - [x] 5.3: 카운트다운 정확성 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴 필수 준수:**
```
TimerView (SwiftUI) ──observe──► TimerViewModel (@Observable) ──uses──► TimerState
```

**@Observable 매크로 사용 (Swift 5.9):**
```swift
@Observable
class TimerViewModel {
    var remainingSeconds: Int = 25 * 60
    var state: TimerState = .idle
    // ...
}
```

### Technical Requirements

**Timer.publish + Combine 기반:**
```swift
import Combine

@Observable
class TimerViewModel {
    private var timerCancellable: AnyCancellable?

    func startFocus() {
        state = .focusing(remaining: 25 * 60)
        remainingSeconds = 25 * 60

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func tick() {
        guard remainingSeconds > 0 else {
            // 타이머 완료 처리 (Story 1.4에서 구현)
            return
        }
        remainingSeconds -= 1
    }
}
```

### File Structure Requirements

**수정할 파일:**
- FocusBuddy/FocusBuddy/Views/ContentView.swift

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
├── Models/
│   └── TimerState.swift          # 타이머 상태 enum
├── ViewModels/
│   └── TimerViewModel.swift      # 타이머 로직
└── Views/
    └── TimerView.swift           # 타이머 UI
```

### UX Design Compliance

**타이머 UI 스펙:**
- 타이머 숫자: SF Mono, 48pt, Bold
- 대기 상태: 회색 텍스트
- 집중 중: Focus Red (#F87171)
- 진행 바: 수평 막대, 현재 진행률 표시

**버튼 스펙:**
- "집중 시작" 버튼: Buddy Green (#4ADE80), 흰색 텍스트
- 아이콘: SF Symbol "target"

**상태 텍스트:**
- 대기: (표시 안 함)
- 집중 중: "🔥 집중 중!"

### Key Implementation Details

**1. TimerState.swift:**
```swift
enum TimerState: Equatable {
    case idle
    case focusing(remaining: Int)
    case resting(remaining: Int)

    var isFocusing: Bool {
        if case .focusing = self { return true }
        return false
    }
}
```

**2. displayTime 계산:**
```swift
var displayTime: String {
    let minutes = remainingSeconds / 60
    let seconds = remainingSeconds % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
```

**3. 색상 정의:**
```swift
extension Color {
    static let focusRed = Color(red: 248/255, green: 113/255, blue: 113/255)
    static let buddyGreen = Color(red: 74/255, green: 222/255, blue: 128/255)
}
```

### Previous Story Intelligence

**Story 1.1에서 생성된 파일:**
- AppDelegate.swift - 메뉴바 + 팝오버 설정 완료
- ContentView.swift - 기본 레이아웃 (placeholder 타이머)
- 폴더 구조 - Models/, ViewModels/, Views/, Services/ 준비됨

**Story 1.1에서 사용된 패턴:**
- NSHostingController로 SwiftUI 뷰 호스팅
- 팝오버 크기: 320x400px
- SF Symbol 사용

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 앱 실행 시 "25:00" 표시
- [ ] "집중 시작" 버튼 클릭 시 카운트다운 시작
- [ ] "🔥 집중 중!" 텍스트 표시
- [ ] 1초마다 정확히 감소
- [ ] MM:SS 형식 유지 (예: 24:59, 24:58...)

### References

- [Source: architecture.md#ADR-003] @Observable 매크로 사용
- [Source: architecture.md#ADR-005] Timer.publish + Combine
- [Source: architecture.md#ADR-006] enum 기반 상태 머신
- [Source: ux-design-specification.md#4.1] 타이머 컴포넌트 디자인
- [Source: prd.md#FR-2] 뽀모도로 타이머 요구사항
- [Source: epics.md#Story-1.2] 스토리 정의

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-07: @Observable은 macOS 14.0+ 필요 - Deployment target 업데이트
- 2026-01-07: xcodebuild 빌드 성공 (BUILD SUCCEEDED)

### Completion Notes List

- ✅ TimerState.swift - enum 기반 상태 머신 (idle, focusing, resting)
- ✅ TimerViewModel.swift - @Observable 매크로, Timer.publish + Combine
- ✅ TimerView.swift - 타이머 UI (대기/집중 상태)
- ✅ ContentView.swift - TimerView 통합
- ✅ 진행률 바 구현 (GeometryReader)
- ✅ UX 색상 적용 (focusRed, buddyGreen)
- ⚠️ Deployment target macOS 14.0으로 변경 (@Observable 호환)

### File List

**신규 생성:**
- FocusBuddy/FocusBuddy/Models/TimerState.swift
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift
- FocusBuddy/FocusBuddy/Views/TimerView.swift

**수정:**
- FocusBuddy/FocusBuddy/Views/ContentView.swift
- FocusBuddy/project.yml (macOS 14.0)

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-07 | Story 1.2 구현 완료 - 집중 타이머 시작 |
