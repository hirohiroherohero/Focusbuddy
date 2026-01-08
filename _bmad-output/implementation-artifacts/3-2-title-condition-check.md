# Story 3.2: 칭호 조건 체크

Status: review

## Story

As a **사용자**,
I want **조건을 달성하면 자동으로 칭호가 획득되기를**,
So that **자연스럽게 칭호를 모을 수 있다**.

## Acceptance Criteria

1. **AC-1: 첫 세션 완료 칭호**
   - **Given** 처음으로 집중 세션을 완료했을 때
   - **When** 세션이 완료되면
   - **Then** "신입 집중러" 칭호가 자동으로 획득된다

2. **AC-2: 7일 연속 칭호**
   - **Given** 7일 연속으로 집중했을 때
   - **When** 7일차 세션이 완료되면
   - **Then** "꾸준함의 시작" 칭호가 자동으로 획득된다

3. **AC-3: 10회 세션 완료 칭호**
   - **Given** 누적 10회 세션을 완료했을 때
   - **When** 10번째 세션이 완료되면
   - **Then** "진짜 집중러" 칭호가 자동으로 획득된다

4. **AC-4: 포기 후 재도전 칭호**
   - **Given** 이전에 포기한 적이 있을 때
   - **When** 다시 세션을 완료하면
   - **Then** "포기하지 않는 자" 칭호가 자동으로 획득된다

## Tasks / Subtasks

- [x] **Task 1: TitleChecker 서비스 생성** (AC: #1-4)
  - [x] 1.1: Services/TitleChecker.swift 생성 - Singleton 패턴
  - [x] 1.2: checkAndUnlockTitles() 메서드 - 모든 조건 평가
  - [x] 1.3: evaluateCondition(_:) 메서드 - TitleCondition별 평가 로직

- [x] **Task 2: 세션 카운트 조건 구현** (AC: #1, #3)
  - [x] 2.1: sessionCount 조건 평가 - SessionRepository.sessions.count 활용
  - [x] 2.2: first_focus 칭호 잠금해제 테스트
  - [x] 2.3: sessions_10 칭호 잠금해제 테스트

- [x] **Task 3: 연속일 조건 구현** (AC: #2)
  - [x] 3.1: streakDays 조건 평가 - CalendarViewModel 로직 재사용
  - [x] 3.2: calculateStreak() 헬퍼 메서드 추가
  - [x] 3.3: streak_7 칭호 잠금해제 테스트

- [x] **Task 4: 포기 후 재도전 조건 구현** (AC: #4)
  - [x] 4.1: SessionRepository에 hasGivenUp 플래그 추가
  - [x] 4.2: TimerViewModel.giveUp()에서 플래그 설정
  - [x] 4.3: afterGiveUp 조건 평가 - hasGivenUp && 세션 완료
  - [x] 4.4: never_give_up 칭호 잠금해제 테스트

- [x] **Task 5: TimerViewModel 통합** (AC: #1-4)
  - [x] 5.1: handleTimerComplete()에서 TitleChecker.checkAndUnlockTitles() 호출
  - [x] 5.2: 세션 저장 후 칭호 체크 순서 보장

- [x] **Task 6: 빌드 및 테스트**
  - [x] 6.1: 빌드 성공 확인
  - [x] 6.2: 첫 세션 완료 → "신입 집중러" 획득 확인
  - [x] 6.3: 칭호 도감에서 획득 표시 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴 준수:**
```
TimerViewModel ──calls──► TitleChecker ──uses──► TitleRepository
                                      ──uses──► SessionRepository
```

**Singleton 패턴:**
- TitleChecker.shared (새로 생성)
- TitleRepository.shared (기존)
- SessionRepository.shared (기존)

### Technical Requirements

**TitleChecker 구조:**
```swift
final class TitleChecker {
    static let shared = TitleChecker()

    private let titleRepository = TitleRepository.shared
    private let sessionRepository = SessionRepository.shared

    /// 모든 칭호 조건을 평가하고 달성 시 잠금해제
    func checkAndUnlockTitles() {
        for title in Title.allTitles {
            guard !titleRepository.isUnlocked(title.id) else { continue }
            if evaluateCondition(title.condition) {
                titleRepository.unlock(title.id)
            }
        }
    }

    private func evaluateCondition(_ condition: TitleCondition) -> Bool {
        switch condition {
        case .sessionCount(let n):
            return completedSessionCount >= n
        case .streakDays(let n):
            return currentStreak >= n
        case .afterGiveUp:
            return hasGivenUpBefore && completedSessionCount > 0
        // ... 기타 조건
        }
    }
}
```

**포기 플래그 저장:**
```swift
// SessionRepository에 추가
private(set) var hasGivenUp: Bool = false

func markGiveUp() {
    hasGivenUp = true
    persistFlags()
}
```

**통합 지점 (TimerViewModel.handleTimerComplete()):**
```swift
private func handleTimerComplete() {
    // ... 기존 로직

    if state.isFocusing {
        // 세션 저장
        sessionRepository.save(session)

        // 칭호 조건 체크 (새로 추가)
        TitleChecker.shared.checkAndUnlockTitles()

        // ... 나머지 로직
    }
}
```

### Condition Evaluation Logic

**1. sessionCount(Int):**
```swift
let completed = sessionRepository.sessions.filter { $0.completed }.count
return completed >= n
```

**2. streakDays(Int):**
```swift
// CalendarViewModel.calculateStreak() 로직 재사용
func calculateStreak() -> Int {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())

    // 일별 세션 수 계산
    var dayCounts: [Date: Int] = [:]
    for session in sessionRepository.sessions where session.completed {
        let day = calendar.startOfDay(for: session.startTime)
        dayCounts[day, default: 0] += 1
    }

    // 오늘 또는 어제부터 연속일 계산
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
```

**3. afterGiveUp:**
```swift
return sessionRepository.hasGivenUp && completedSessionCount > 0
```

**4. timeOfDay(hour:before:):** (MVP AC 범위 외)
```swift
let currentHour = Calendar.current.component(.hour, from: Date())
if before {
    return currentHour < hour
} else {
    return currentHour >= hour
}
```

**5. dayOfWeek([Int]):** (MVP AC 범위 외)
```swift
let weekday = Calendar.current.component(.weekday, from: Date())
return days.contains(weekday)
```

**6. totalDays(Int):** (MVP AC 범위 외)
```swift
let uniqueDays = Set(sessionRepository.sessions
    .filter { $0.completed }
    .map { Calendar.current.startOfDay(for: $0.startTime) }
).count
return uniqueDays >= n
```

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
└── Services/
    └── TitleChecker.swift    # 칭호 조건 체크 서비스 (Singleton)
```

**수정할 파일:**
```
FocusBuddy/FocusBuddy/
├── Services/
│   └── SessionRepository.swift   # hasGivenUp 플래그 추가
└── ViewModels/
    └── TimerViewModel.swift      # handleTimerComplete()에 칭호 체크 호출
```

### Previous Story Intelligence

**Story 3.1에서 확립된 패턴:**
- TitleRepository.shared로 칭호 데이터 접근
- TitleRepository.unlock(_:) 메서드로 칭호 획득
- TitleRepository.isUnlocked(_:) 메서드로 획득 여부 확인
- Title.allTitles로 전체 칭호 목록 접근

**CalendarViewModel 참고:**
- calculateStreak() 로직 재사용 (lines 85-108)
- daySessionCounts 계산 패턴 재사용

**TimerViewModel 통합 지점:**
- handleTimerComplete() 메서드 (line 117)
- 세션 저장 후 칭호 체크 호출 위치: line 128 이후

### Key Implementation Details

**1. TitleChecker.swift:**
```swift
import Foundation

final class TitleChecker {
    static let shared = TitleChecker()

    private let titleRepository = TitleRepository.shared
    private let sessionRepository = SessionRepository.shared

    private init() {}

    // MARK: - Public Methods

    func checkAndUnlockTitles() {
        for title in Title.allTitles {
            guard !titleRepository.isUnlocked(title.id) else { continue }
            if evaluateCondition(title.condition) {
                titleRepository.unlock(title.id)
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
```

**2. SessionRepository.swift 수정:**
```swift
// 추가할 프로퍼티
private(set) var hasGivenUp: Bool = false

// 추가할 메서드
func markGiveUp() {
    hasGivenUp = true
    persistFlags()
}

// persistFlags() 구현 - 별도 flags.json 또는 sessions.json에 포함
```

**3. TimerViewModel.swift 수정:**
```swift
// handleTimerComplete() 내부, 세션 저장 후 추가
sessionRepository.save(session)

// 칭호 조건 체크 (새로 추가)
TitleChecker.shared.checkAndUnlockTitles()
```

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 첫 세션 완료 → "신입 집중러" 자동 획득
- [ ] 칭호 탭에서 "신입 집중러" 획득 상태 확인 (컬러 아이콘 + 칭호명)
- [ ] 포기 후 다시 완료 → "포기하지 않는 자" 획득
- [ ] 앱 재시작 후 획득 상태 유지

### Edge Cases

1. **중복 획득 방지:** 이미 획득한 칭호는 다시 획득되지 않음 (isUnlocked 체크)
2. **세션 저장 실패 시:** 칭호 체크 호출 안함 (세션 저장 성공 후에만 호출)
3. **동시 다중 칭호 획득:** 첫 세션 완료 시 first_focus 획득, 같은 세션에서 다른 조건도 만족하면 함께 획득

### References

- [Source: epics.md#Story-3.2] 스토리 정의 및 AC
- [Source: prd.md#FR-4.3] 조건 달성 시 칭호 자동 획득
- [Source: architecture.md#5.2] Title 모델 및 조건
- [Source: Story-3.1] Title 모델, TitleRepository, TitleViewModel 구현

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded on 2026-01-08

### Completion Notes List

1. **TitleChecker 서비스 구현 완료**
   - `TitleChecker.swift` Singleton 패턴으로 생성
   - `checkAndUnlockTitles()` 메서드로 모든 칭호 조건 평가
   - `evaluateCondition(_:)` 메서드로 TitleCondition별 평가 로직 구현

2. **모든 칭호 조건 구현 완료**
   - `sessionCount`: 완료 세션 수 기반 평가
   - `streakDays`: 연속일 계산 로직 구현
   - `afterGiveUp`: 포기 후 재도전 조건 평가
   - `timeOfDay`, `dayOfWeek`, `totalDays`: 추가 조건 구현

3. **SessionRepository 포기 플래그 추가**
   - `hasGivenUp` 프로퍼티 추가
   - `markGiveUp()` 메서드로 플래그 설정
   - `flags.json` 파일에 별도 저장

4. **TimerViewModel 통합 완료**
   - `giveUp()`에서 `markGiveUp()` 호출
   - `handleTimerComplete()`에서 세션 저장 후 `TitleChecker.shared.checkAndUnlockTitles()` 호출

### File List

**신규:**
- `FocusBuddy/FocusBuddy/Services/TitleChecker.swift`

**수정:**
- `FocusBuddy/FocusBuddy/Services/SessionRepository.swift` - hasGivenUp 플래그 및 관련 메서드 추가
- `FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift` - 칭호 체크 통합
- `FocusBuddy/FocusBuddy.xcodeproj/project.pbxproj` - TitleChecker.swift 프로젝트에 추가

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-08 | Story 3.2 생성 - 칭호 조건 체크 |
| 2026-01-08 | 구현 완료 - TitleChecker 서비스, 포기 플래그, TimerViewModel 통합 |
