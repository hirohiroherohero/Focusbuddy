# Story 2.1: 잔디 캘린더 기본 UI

Status: done

## Story

As a **사용자**,
I want **GitHub 스타일 연간 캘린더를 볼 수 있기를**,
So that **내 집중 기록을 한눈에 볼 수 있다**.

## Acceptance Criteria

1. **AC-1: 잔디 탭 접근**
   - **Given** 팝오버가 열린 상태에서
   - **When** "📅 잔디" 탭을 클릭하면
   - **Then** 52주 x 7일 그리드 형태의 잔디 캘린더가 표시된다

2. **AC-2: 오늘 날짜 하이라이트**
   - **Given** 잔디 캘린더가 표시될 때
   - **When** 오늘 날짜 셀을 확인하면
   - **Then** 오늘 날짜가 테두리로 하이라이트 표시된다

## Tasks / Subtasks

- [x] **Task 1: 탭 네비게이션 구현** (AC: #1)
  - [x] 1.1: ContentView에 TabView 또는 custom tab bar 추가
  - [x] 1.2: 홈(🏠), 잔디(📅), 칭호(🏅), 설정(⚙️) 탭 구조 생성
  - [x] 1.3: 탭 전환 애니메이션 (0.2s slide + fade)
  - [x] 1.4: 기본 탭은 홈(TimerView)으로 설정

- [x] **Task 2: CalendarViewModel 생성** (AC: #1, #2)
  - [x] 2.1: ViewModels/CalendarViewModel.swift 생성 - @Observable 매크로 사용
  - [x] 2.2: SessionRepository.shared 의존성 주입
  - [x] 2.3: 날짜별 세션 횟수 계산 로직 구현 (sessions → daySessionCounts Dictionary)
  - [x] 2.4: 52주 x 7일 날짜 배열 생성 (오늘 기준 과거 1년)
  - [x] 2.5: isToday(date:) 헬퍼 메서드

- [x] **Task 3: GrassCalendarView 생성** (AC: #1, #2)
  - [x] 3.1: Views/GrassCalendarView.swift 생성
  - [x] 3.2: LazyHGrid 기반 52주 x 7일 그리드 레이아웃
  - [x] 3.3: 각 셀에 GrassCell 컴포넌트 사용
  - [x] 3.4: 스크롤 가능한 수평 레이아웃 (최근 주가 오른쪽)
  - [x] 3.5: 연도 표시 헤더

- [x] **Task 4: GrassCell 컴포넌트 생성** (AC: #1, #2)
  - [x] 4.1: Views/Components/GrassCell.swift 생성
  - [x] 4.2: 셀 크기: 10x10pt (간격 2pt)
  - [x] 4.3: 세션 횟수에 따른 색상 적용 (grassColor 함수)
  - [x] 4.4: 오늘 날짜 테두리 표시 (1pt, Buddy Green)
  - [x] 4.5: 라운드 코너 (2pt)

- [x] **Task 5: 잔디 색상 로직** (AC: #1)
  - [x] 5.1: Color extension에 잔디 색상 추가
  - [x] 5.2: grassColor(for sessionCount: Int) -> Color 함수 구현
  - [x] 5.3: 0회=#EBEDF0, 1회=#9BE9A8, 2회=#40C463, 3회+=#30A14E

- [x] **Task 6: 빌드 및 테스트**
  - [x] 6.1: 빌드 성공 확인
  - [x] 6.2: 탭 전환 동작 확인
  - [x] 6.3: 잔디 캘린더 그리드 표시 확인
  - [x] 6.4: 오늘 날짜 하이라이트 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴 필수 준수:**
```
GrassCalendarView (SwiftUI) ──observe──► CalendarViewModel (@Observable) ──uses──► SessionRepository
```

**@Observable 매크로 사용 (Swift 5.9):**
```swift
@Observable
class CalendarViewModel {
    private let sessionRepository = SessionRepository.shared

    var daySessionCounts: [Date: Int] = [:]
    var calendarDays: [[Date?]] = []  // 52주 x 7일

    func loadData() {
        // SessionRepository에서 세션 로드 후 날짜별 집계
    }
}
```

### Technical Requirements

**52주 x 7일 그리드 계산:**
```swift
func generateCalendarDays() -> [[Date?]] {
    var weeks: [[Date?]] = []
    let calendar = Calendar.current
    let today = Date()

    // 오늘이 포함된 주의 일요일 찾기
    let weekday = calendar.component(.weekday, from: today)
    let daysToAdd = 7 - weekday  // 토요일까지
    let endOfWeek = calendar.date(byAdding: .day, value: daysToAdd, to: today)!

    // 52주 전으로 거슬러 올라가기
    var currentDate = calendar.date(byAdding: .weekOfYear, value: -51, to: endOfWeek)!

    for _ in 0..<52 {
        var week: [Date?] = []
        for _ in 0..<7 {
            week.append(currentDate)
            currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
        }
        weeks.append(week)
    }

    return weeks
}
```

**날짜별 세션 횟수 계산:**
```swift
func calculateDaySessionCounts() {
    let sessions = sessionRepository.sessions
    var counts: [Date: Int] = [:]

    for session in sessions where session.completed {
        let day = Calendar.current.startOfDay(for: session.startTime)
        counts[day, default: 0] += 1
    }

    daySessionCounts = counts
}
```

### UX Design Compliance

**잔디 색상 강도 (UX Design Spec 기준):**
```swift
extension Color {
    static let grass0 = Color(hex: "#EBEDF0")  // 0회 - 빈 칸
    static let grass1 = Color(hex: "#9BE9A8")  // 1회 - 연한 초록
    static let grass2 = Color(hex: "#40C463")  // 2회 - 중간 초록
    static let grass3 = Color(hex: "#30A14E")  // 3회+ - 진한 초록

    static func grassColor(for count: Int) -> Color {
        switch count {
        case 0: return .grass0
        case 1: return .grass1
        case 2: return .grass2
        default: return .grass3
        }
    }
}
```

**오늘 날짜 하이라이트:**
```swift
// GrassCell.swift
if isToday {
    cell.overlay(
        RoundedRectangle(cornerRadius: 2)
            .stroke(Color.buddyGreen, lineWidth: 1)
    )
}
```

**탭 구조 (UX Design Spec 기준):**
```
[🏠 홈]  [📅 잔디]  [🏅 칭호]  [⚙️ 설정]
```

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
├── ViewModels/
│   └── CalendarViewModel.swift     # 잔디 캘린더 로직
├── Views/
│   ├── GrassCalendarView.swift     # 잔디 캘린더 메인 뷰
│   └── Components/
│       └── GrassCell.swift         # 잔디 셀 컴포넌트
```

**수정할 파일:**
```
FocusBuddy/FocusBuddy/
├── Views/
│   └── ContentView.swift           # 탭 네비게이션 추가
└── Views/
    └── TimerView.swift             # Color extension에 잔디 색상 추가 (또는 별도 파일)
```

### Previous Story Intelligence

**Epic 1에서 확립된 패턴:**
- @Observable 매크로 사용 (Swift 5.9, macOS 14.0+)
- Services는 싱글톤 패턴 (`.shared`)
- SessionRepository.shared로 세션 데이터 접근
- SessionRecord 모델: `startTime`, `endTime`, `completed`, `date` (computed)
- Color extension은 TimerView.swift에 정의됨 (focusRed, buddyGreen, restBlue)
- SwiftUI Preview 포함

**SessionRepository 사용 패턴:**
```swift
let sessions = SessionRepository.shared.sessions  // [SessionRecord]
```

**SessionRecord.date 사용:**
```swift
// SessionRecord.swift에 이미 정의됨
var date: Date {
    Calendar.current.startOfDay(for: startTime)
}
```

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 앱 실행 시 탭 바 표시 확인
- [ ] 각 탭 클릭 시 화면 전환 확인
- [ ] "📅 잔디" 탭 클릭 시 캘린더 표시 확인
- [ ] 52주 x 7일 그리드 형태 확인
- [ ] 오늘 날짜 테두리 하이라이트 확인
- [ ] 세션 기록이 있는 날짜 색상 확인 (테스트 데이터 필요)
- [ ] 다크모드/라이트모드 전환 시 색상 확인

### Key Implementation Details

**1. ContentView 탭 구조:**
```swift
struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            // 헤더
            headerView
            Divider()

            // 탭 콘텐츠
            TabView(selection: $selectedTab) {
                TimerView(viewModel: TimerViewModel.shared)
                    .tag(0)
                GrassCalendarView()
                    .tag(1)
                // 칭호, 설정은 추후 스토리에서 구현
                Text("칭호 (준비 중)").tag(2)
                Text("설정 (준비 중)").tag(3)
            }
            .tabViewStyle(.automatic)

            // 탭 바
            tabBar
        }
        .frame(width: 320, height: 400)
    }

    private var tabBar: some View {
        HStack {
            TabButton(icon: "house.fill", label: "홈", tag: 0, selected: $selectedTab)
            TabButton(icon: "calendar", label: "잔디", tag: 1, selected: $selectedTab)
            TabButton(icon: "trophy.fill", label: "칭호", tag: 2, selected: $selectedTab)
            TabButton(icon: "gearshape.fill", label: "설정", tag: 3, selected: $selectedTab)
        }
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}
```

**2. LazyVGrid 기반 캘린더:**
```swift
struct GrassCalendarView: View {
    @State private var viewModel = CalendarViewModel()

    private let columns = Array(repeating: GridItem(.fixed(10), spacing: 2), count: 7)

    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: Array(repeating: GridItem(.fixed(10), spacing: 2), count: 7)) {
                ForEach(viewModel.flattenedDays, id: \.self) { date in
                    GrassCell(
                        sessionCount: viewModel.sessionCount(for: date),
                        isToday: viewModel.isToday(date)
                    )
                }
            }
            .padding()
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}
```

### Important Notes

**TabView vs Custom Tab Bar:**
- macOS에서 TabView는 제한적이므로 custom tab bar 권장
- 팝오버 크기(320x400)에 맞는 컴팩트한 디자인 필요

**Color Hex Extension:**
```swift
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}
```

### References

- [Source: epics.md#Story-2.1] 스토리 정의 및 AC
- [Source: architecture.md#4.1] 프로젝트 구조 (GrassCalendarView, CalendarViewModel)
- [Source: architecture.md#6.1] 잔디 색상 계산 알고리즘
- [Source: ux-design-specification.md#2] 잔디 색상 강도 정의
- [Source: ux-design-specification.md#3] 탭 구조 및 팝오버 크기
- [Source: ux-design-specification.md#4.2] 잔디 캘린더 컴포넌트 디자인
- [Source: prd.md#FR-3.1] 연간 캘린더 그리드 표시
- [Source: prd.md#FR-3.4] 오늘 날짜 하이라이트

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-08: BUILD SUCCEEDED

### Completion Notes List

- ✅ ContentView.swift - Custom tab bar 추가 (홈, 잔디, 칭호, 설정)
- ✅ TabButton 컴포넌트 - 탭 전환 애니메이션 (0.2s easeInOut)
- ✅ CalendarViewModel.swift - @Observable, 52주 x 7일 날짜 생성
- ✅ CalendarViewModel - daySessionCounts 계산, isToday() 헬퍼
- ✅ GrassCalendarView.swift - LazyHGrid, 수평 스크롤, 연도 헤더
- ✅ GrassCalendarView - 범례 (적음 ↔ 많음) 추가
- ✅ GrassCell.swift - 10x10pt 셀, 라운드 코너 2pt
- ✅ GrassCell - 오늘 날짜 테두리 (Buddy Green)
- ✅ Color extension - hex init, grass0~3 색상, grassColor(for:) 함수

### File List

**신규 생성:**
- FocusBuddy/FocusBuddy/ViewModels/CalendarViewModel.swift
- FocusBuddy/FocusBuddy/Views/GrassCalendarView.swift
- FocusBuddy/FocusBuddy/Views/Components/GrassCell.swift

**수정:**
- FocusBuddy/FocusBuddy/Views/ContentView.swift (탭 네비게이션 추가)
- FocusBuddy/FocusBuddy/Views/TimerView.swift (Color extension에 잔디 색상 추가)

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-08 | Story 2.1 생성 - 잔디 캘린더 기본 UI |
| 2026-01-08 | Story 2.1 구현 완료 - 탭 네비게이션, 잔디 캘린더 |
