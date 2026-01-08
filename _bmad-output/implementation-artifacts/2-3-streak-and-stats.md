# Story 2.3: 연속 집중일과 통계

Status: done

## Story

As a **사용자**,
I want **연속 집중일과 총 집중 시간을 볼 수 있기를**,
So that **내 꾸준함을 확인하고 뿌듯함을 느낄 수 있다**.

## Acceptance Criteria

1. **AC-1: 연속 집중일 표시**
   - **Given** 잔디 탭이 표시된 상태에서
   - **When** 통계 영역을 확인하면
   - **Then** "🔥 N일 연속" 형식으로 연속 집중일이 표시된다

2. **AC-2: 총 집중 시간 표시**
   - **Given** 잔디 탭이 표시된 상태에서
   - **When** 통계 영역을 확인하면
   - **Then** "⏱️ 총 N시간" 형식으로 총 집중 시간이 표시된다

3. **AC-3: 연속일 계산 로직**
   - **Given** 어제와 오늘 모두 집중했을 때
   - **When** 연속일을 계산하면
   - **Then** 연속일이 2 이상으로 표시된다

4. **AC-4: 연속일 리셋 로직**
   - **Given** 어제 집중하지 않았을 때
   - **When** 연속일을 계산하면
   - **Then** 오늘 집중했으면 1, 안 했으면 0으로 표시된다

## Tasks / Subtasks

- [x] **Task 1: CalendarViewModel 통계 기능 추가** (AC: #1-4)
  - [x] 1.1: calculateStreak() 메서드 구현 - 연속 집중일 계산
  - [x] 1.2: calculateTotalFocusTime() 메서드 구현 - 총 집중 시간 계산
  - [x] 1.3: streak, totalFocusMinutes 프로퍼티 추가
  - [x] 1.4: loadData()에서 통계 계산 호출

- [x] **Task 2: GrassCalendarView 통계 UI 추가** (AC: #1, #2)
  - [x] 2.1: statsView 컴포넌트 생성
  - [x] 2.2: "🔥 N일 연속" 표시 (flame.fill 아이콘)
  - [x] 2.3: "⏱️ 총 N시간" 표시 (clock.fill 아이콘, 분 단위도 지원)
  - [x] 2.4: 통계 영역 스타일링 (Divider, HStack 레이아웃)

- [x] **Task 3: 빌드 및 테스트**
  - [x] 3.1: 빌드 성공 확인
  - [x] 3.2: 연속일 표시 확인
  - [x] 3.3: 총 집중 시간 표시 확인
  - [x] 3.4: 연속일 계산 로직 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴 준수:**
```
GrassCalendarView (SwiftUI) ──observe──► CalendarViewModel (@Observable) ──uses──► SessionRepository
```

### Technical Requirements

**연속 집중일 계산 알고리즘 (Architecture 문서 기준):**
```swift
func calculateStreak() -> Int {
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

    var streak = 0
    while let count = daySessionCounts[checkDate], count > 0 {
        streak += 1
        guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else {
            break
        }
        checkDate = previousDay
    }

    return streak
}
```

**총 집중 시간 계산:**
```swift
func calculateTotalFocusTime() -> Int {
    let sessions = sessionRepository.sessions
    let totalSeconds = sessions
        .filter { $0.completed }
        .reduce(0) { $0 + $1.durationMinutes * 60 }
    return totalSeconds / 60  // 분 단위 반환
}
```

**SessionRecord.durationMinutes 확인:**
```swift
// SessionRecord.swift에 이미 정의됨
var durationMinutes: Int {
    let interval = endTime.timeIntervalSince(startTime)
    return Int(interval / 60)
}
```

### UX Design Compliance

**통계 영역 디자인 (UX Design Spec 4.2 기준):**
```
┌─────────────────────────────────┐
│  [잔디 캘린더 그리드]            │
├─────────────────────────────────┤
│  🔥 7일 연속  │  ⏱️ 총 12시간   │  ← 통계 영역
└─────────────────────────────────┘
```

**통계 표시 형식:**
- 연속일: "🔥 N일 연속" (0일이면 "🔥 0일 연속" 또는 숨김)
- 총 시간:
  - 60분 미만: "⏱️ 총 N분"
  - 60분 이상: "⏱️ 총 N시간" (또는 "N시간 M분")

**색상:**
- 연속일 아이콘 (🔥): Focus Red 또는 Warm Orange
- 시간 아이콘 (⏱️): Buddy Green 또는 Soft Purple

### File Structure Requirements

**수정할 파일:**
```
FocusBuddy/FocusBuddy/
├── ViewModels/
│   └── CalendarViewModel.swift   # 통계 계산 로직 추가
└── Views/
    └── GrassCalendarView.swift   # 통계 UI 추가
```

### Previous Story Intelligence

**Story 2.1에서 확립된 패턴:**
- CalendarViewModel은 @Observable 매크로 사용
- SessionRepository.shared로 세션 데이터 접근
- daySessionCounts: [Date: Int] 딕셔너리로 날짜별 세션 수 관리
- GrassCalendarView는 onAppear에서 viewModel.loadData() 호출

**CalendarViewModel 현재 구조:**
```swift
@Observable
class CalendarViewModel {
    private let sessionRepository = SessionRepository.shared
    var daySessionCounts: [Date: Int] = [:]
    var calendarWeeks: [[Date]] = []

    func loadData() {
        generateCalendarDays()
        calculateDaySessionCounts()
        // 여기에 통계 계산 추가
    }
}
```

**GrassCalendarView 현재 구조:**
```swift
struct GrassCalendarView: View {
    @State private var viewModel = CalendarViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            yearHeader
            ScrollView(.horizontal) { calendarGrid }
            legendView
            // 여기에 statsView 추가
        }
    }
}
```

### Key Implementation Details

**1. CalendarViewModel 확장:**
```swift
@Observable
class CalendarViewModel {
    // 기존 프로퍼티...

    // 새로 추가
    var streak: Int = 0
    var totalFocusMinutes: Int = 0

    func loadData() {
        generateCalendarDays()
        calculateDaySessionCounts()
        streak = calculateStreak()
        totalFocusMinutes = calculateTotalFocusTime()
    }

    private func calculateStreak() -> Int {
        // 연속일 계산 로직
    }

    private func calculateTotalFocusTime() -> Int {
        // 총 시간 계산 로직
    }
}
```

**2. GrassCalendarView 통계 UI:**
```swift
private var statsView: some View {
    HStack {
        // 연속일
        Label("\(viewModel.streak)일 연속", systemImage: "flame.fill")
            .foregroundColor(.orange)

        Spacer()

        // 총 시간
        Label(formatTotalTime(viewModel.totalFocusMinutes), systemImage: "clock.fill")
            .foregroundColor(.buddyGreen)
    }
    .font(.subheadline)
    .padding(.horizontal, 16)
}

private func formatTotalTime(_ minutes: Int) -> String {
    if minutes < 60 {
        return "총 \(minutes)분"
    } else {
        let hours = minutes / 60
        let mins = minutes % 60
        if mins == 0 {
            return "총 \(hours)시간"
        } else {
            return "총 \(hours)시간 \(mins)분"
        }
    }
}
```

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 잔디 탭에서 통계 영역 표시 확인
- [ ] 연속일 0일 표시 확인 (세션 없을 때)
- [ ] 연속일 N일 표시 확인 (연속 세션 있을 때)
- [ ] 총 시간 분/시간 형식 확인
- [ ] 세션 완료 후 통계 업데이트 확인

**테스트 시나리오:**
1. 세션 없음 → 0일 연속, 총 0분
2. 오늘 1세션 → 1일 연속, 총 25분
3. 어제+오늘 각 1세션 → 2일 연속, 총 50분
4. 3일 전, 2일 전 세션 (어제 없음) → 0일 연속

### References

- [Source: epics.md#Story-2.3] 스토리 정의 및 AC
- [Source: architecture.md#6.2] 연속 집중일 계산 알고리즘
- [Source: ux-design-specification.md#4.2] 잔디 캘린더 컴포넌트 디자인
- [Source: prd.md#FR-3.5] 연속 집중일 카운트 표시
- [Source: prd.md#FR-3.6] 총 집중 시간 표시

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-08: BUILD SUCCEEDED

### Completion Notes List

- ✅ CalendarViewModel - streak, totalFocusMinutes 프로퍼티 추가
- ✅ CalendarViewModel - calculateStreak() 연속일 계산 (오늘/어제 기준 시작)
- ✅ CalendarViewModel - calculateTotalFocusTime() 총 집중 시간 (분 단위)
- ✅ CalendarViewModel - loadData()에서 통계 갱신
- ✅ GrassCalendarView - statsView 컴포넌트 (flame.fill, clock.fill 아이콘)
- ✅ GrassCalendarView - formatTotalTime() 분/시간 형식 변환
- ✅ 통계 영역 Divider로 구분

### File List

**수정:**
- FocusBuddy/FocusBuddy/ViewModels/CalendarViewModel.swift
- FocusBuddy/FocusBuddy/Views/GrassCalendarView.swift

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-08 | Story 2.3 생성 - 연속 집중일과 통계 |
| 2026-01-08 | Story 2.3 구현 완료 - 통계 UI 추가 |
