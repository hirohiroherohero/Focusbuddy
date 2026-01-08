# Story 3.1: 칭호 도감 UI

Status: done

## Story

As a **사용자**,
I want **칭호 도감에서 모든 칭호를 볼 수 있기를**,
So that **어떤 칭호가 있는지 확인하고 수집 욕구를 느낄 수 있다**.

## Acceptance Criteria

1. **AC-1: 칭호 탭 접근**
   - **Given** 팝오버가 열린 상태에서
   - **When** "🏅 칭호" 탭을 클릭하면
   - **Then** 10개의 칭호 카드가 그리드로 표시된다

2. **AC-2: 획득 칭호 표시**
   - **Given** 획득한 칭호가 있을 때
   - **When** 해당 칭호 카드를 확인하면
   - **Then** 컬러 아이콘과 칭호명이 표시된다

3. **AC-3: 미획득 칭호 표시**
   - **Given** 미획득 칭호가 있을 때
   - **When** 해당 칭호 카드를 확인하면
   - **Then** 회색 아이콘과 "???" 텍스트가 표시된다

## Tasks / Subtasks

- [x] **Task 1: Title 모델 생성** (AC: #1-3)
  - [x] 1.1: Title.swift 생성 - id, name, icon, condition, unlockedAt 프로퍼티
  - [x] 1.2: TitleCondition enum 정의 - sessionCount, streakDays 등
  - [x] 1.3: 10개 MVP 칭호 정적 데이터 정의

- [x] **Task 2: TitleRepository 생성** (AC: #2, #3)
  - [x] 2.1: TitleRepository.swift 생성 - SessionRepository 패턴 따름
  - [x] 2.2: titles.json 저장/로드 구현
  - [x] 2.3: unlock(_:) 메서드 구현 - 칭호 획득 처리

- [x] **Task 3: TitleViewModel 생성** (AC: #1-3)
  - [x] 3.1: TitleViewModel.swift 생성 - @Observable 매크로 사용
  - [x] 3.2: titles 프로퍼티 - 전체 칭호 목록
  - [x] 3.3: unlockedTitles, lockedTitles computed 프로퍼티

- [x] **Task 4: TitleCard 컴포넌트 생성** (AC: #2, #3)
  - [x] 4.1: Components/TitleCard.swift 생성
  - [x] 4.2: 획득 상태 UI - 컬러 아이콘 + 칭호명
  - [x] 4.3: 미획득 상태 UI - 회색 + "???"

- [x] **Task 5: TitleCollectionView 생성** (AC: #1)
  - [x] 5.1: Views/TitleCollectionView.swift 생성
  - [x] 5.2: LazyVGrid로 2열 그리드 레이아웃
  - [x] 5.3: TitleCard 매핑

- [x] **Task 6: ContentView 연결** (AC: #1)
  - [x] 6.1: 칭호 탭 placeholder 교체
  - [x] 6.2: TitleCollectionView 연결

- [x] **Task 7: 빌드 및 테스트**
  - [x] 7.1: 빌드 성공 확인
  - [x] 7.2: 칭호 탭 표시 확인
  - [x] 7.3: 10개 칭호 카드 표시 확인
  - [x] 7.4: 미획득 상태 회색/"???" 표시 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴 준수:**
```
TitleCollectionView (SwiftUI) ──observe──► TitleViewModel (@Observable) ──uses──► TitleRepository
```

**Singleton 패턴:**
- TitleRepository.shared (SessionRepository 패턴 따름)

### Technical Requirements

**MVP 10개 칭호 목록 (PRD 기준):**

| # | ID | 칭호명 | 아이콘 | 조건 |
|---|-----|-------|-------|------|
| 1 | first_focus | 신입 집중러 | 🌱 | 첫 세션 완료 |
| 2 | never_give_up | 포기하지 않는 자 | 💪 | 포기 후 다시 완료 |
| 3 | streak_7 | 꾸준함의 시작 | 🔥 | 7일 연속 |
| 4 | sessions_10 | 진짜 집중러 | 🏅 | 10회 세션 완료 |
| 5 | early_bird | 아침형 인간 | 🌅 | 오전 9시 이전 완료 |
| 6 | night_owl | 올빼미 | 🦉 | 자정 이후 완료 |
| 7 | weekend_warrior | 주말 전사 | ⚔️ | 토/일요일 완료 |
| 8 | streak_30 | 한 달의 기적 | ✨ | 30일 연속 |
| 9 | sessions_50 | 집중 마스터 | 👑 | 50회 세션 완료 |
| 10 | days_100 | 100일의 기록 | 📜 | 100일 사용 |

**Title 모델 구조:**
```swift
struct Title: Codable, Identifiable {
    let id: String              // "first_focus", "streak_7" 등
    let name: String            // "신입 집중러"
    let icon: String            // "🌱"
    let description: String     // "첫 세션 완료"
    let condition: TitleCondition
    var unlockedAt: Date?       // nil이면 미획득

    var isUnlocked: Bool { unlockedAt != nil }
}

enum TitleCondition: Codable {
    case sessionCount(Int)      // N회 세션 완료
    case streakDays(Int)        // N일 연속
    case timeOfDay(hour: Int, before: Bool)  // 특정 시간
    case dayOfWeek([Int])       // 특정 요일 (1=일, 7=토)
    case totalDays(Int)         // 총 사용일
    case afterGiveUp            // 포기 후 재도전
}
```

**TitleRepository 저장 경로:**
```
~/Library/Application Support/FocusBuddy/titles.json
```

### UX Design Compliance

**칭호 카드 디자인 (UX Spec 4.3 기준):**

**획득한 칭호:**
```
┌─────────────────┐
│      🌱         │  ← 컬러 아이콘 (48x48)
│  신입 집중러    │  ← 칭호명 (12pt Medium)
└─────────────────┘
```

**미획득 칭호:**
```
┌─────────────────┐
│      ❓         │  ← 회색/물음표
│  ???           │  ← 숨겨진 이름
└─────────────────┘
```

**그리드 레이아웃:**
- 2열 그리드 (5행 x 2열 = 10개)
- 카드 간격: 12pt
- 패딩: 16pt

**색상:**
- 획득: 아이콘 원본 색상, 텍스트 기본 색상
- 미획득: 아이콘 Gray (#9CA3AF), 텍스트 Secondary

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
├── Models/
│   └── Title.swift              # 칭호 모델 + TitleCondition enum
├── Services/
│   └── TitleRepository.swift    # 칭호 저장소 (Singleton)
├── ViewModels/
│   └── TitleViewModel.swift     # 칭호 뷰모델 (@Observable)
└── Views/
    ├── TitleCollectionView.swift # 칭호 도감 메인 뷰
    └── Components/
        └── TitleCard.swift       # 칭호 카드 컴포넌트
```

**수정할 파일:**
```
FocusBuddy/FocusBuddy/Views/ContentView.swift  # 칭호 탭 연결
```

### Previous Story Intelligence

**Story 2.3에서 확립된 패턴:**
- @Observable 매크로로 ViewModel 정의
- SessionRepository.shared로 싱글톤 데이터 접근
- loadData() 패턴으로 onAppear에서 데이터 로드
- LazyHGrid/LazyVGrid로 그리드 레이아웃

**ContentView 현재 구조 (칭호 탭 placeholder):**
```swift
case 2:
    placeholderView(title: "🏅 칭호", message: "준비 중...")
        .transition(.opacity)
```
→ TitleCollectionView()로 교체 필요

**Color extension 위치:**
- TimerView.swift에 Color extension 정의됨
- buddyGreen, grass0~3 등 색상 정의

### Key Implementation Details

**1. Title.swift:**
```swift
import Foundation

struct Title: Codable, Identifiable {
    let id: String
    let name: String
    let icon: String
    let description: String
    let condition: TitleCondition
    var unlockedAt: Date?

    var isUnlocked: Bool { unlockedAt != nil }
}

enum TitleCondition: Codable {
    case sessionCount(Int)
    case streakDays(Int)
    case timeOfDay(hour: Int, before: Bool)
    case dayOfWeek([Int])
    case totalDays(Int)
    case afterGiveUp
}

// MARK: - Static Data (10 MVP Titles)
extension Title {
    static let allTitles: [Title] = [
        Title(id: "first_focus", name: "신입 집중러", icon: "🌱",
              description: "첫 세션 완료", condition: .sessionCount(1)),
        Title(id: "never_give_up", name: "포기하지 않는 자", icon: "💪",
              description: "포기 후 다시 완료", condition: .afterGiveUp),
        Title(id: "streak_7", name: "꾸준함의 시작", icon: "🔥",
              description: "7일 연속", condition: .streakDays(7)),
        Title(id: "sessions_10", name: "진짜 집중러", icon: "🏅",
              description: "10회 세션 완료", condition: .sessionCount(10)),
        Title(id: "early_bird", name: "아침형 인간", icon: "🌅",
              description: "오전 9시 이전 완료", condition: .timeOfDay(hour: 9, before: true)),
        Title(id: "night_owl", name: "올빼미", icon: "🦉",
              description: "자정 이후 완료", condition: .timeOfDay(hour: 0, before: false)),
        Title(id: "weekend_warrior", name: "주말 전사", icon: "⚔️",
              description: "토/일요일 완료", condition: .dayOfWeek([1, 7])),
        Title(id: "streak_30", name: "한 달의 기적", icon: "✨",
              description: "30일 연속", condition: .streakDays(30)),
        Title(id: "sessions_50", name: "집중 마스터", icon: "👑",
              description: "50회 세션 완료", condition: .sessionCount(50)),
        Title(id: "days_100", name: "100일의 기록", icon: "📜",
              description: "100일 사용", condition: .totalDays(100)),
    ]
}
```

**2. TitleRepository.swift:**
```swift
import Foundation

final class TitleRepository {
    static let shared = TitleRepository()

    private let fileManager = FileManager.default

    private var titlesURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let focusBuddy = appSupport.appendingPathComponent("FocusBuddy", isDirectory: true)
        return focusBuddy.appendingPathComponent("titles.json")
    }

    private(set) var unlockedTitleIds: Set<String> = []
    private(set) var unlockDates: [String: Date] = [:]

    private init() {
        createDirectoryIfNeeded()
        load()
    }

    func unlock(_ titleId: String) {
        guard !unlockedTitleIds.contains(titleId) else { return }
        unlockedTitleIds.insert(titleId)
        unlockDates[titleId] = Date()
        persist()
    }

    func isUnlocked(_ titleId: String) -> Bool {
        unlockedTitleIds.contains(titleId)
    }

    // ... createDirectoryIfNeeded, load, persist 구현
}
```

**3. TitleViewModel.swift:**
```swift
import Foundation

@Observable
class TitleViewModel {
    private let titleRepository = TitleRepository.shared

    var titles: [Title] {
        Title.allTitles.map { title in
            var t = title
            t.unlockedAt = titleRepository.unlockDates[title.id]
            return t
        }
    }

    var unlockedCount: Int {
        titles.filter { $0.isUnlocked }.count
    }

    func loadData() {
        titleRepository.load()
    }
}
```

**4. TitleCard.swift:**
```swift
struct TitleCard: View {
    let title: Title

    var body: some View {
        VStack(spacing: 8) {
            Text(title.isUnlocked ? title.icon : "❓")
                .font(.system(size: 36))

            Text(title.isUnlocked ? title.name : "???")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(title.isUnlocked ? .primary : .secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .opacity(title.isUnlocked ? 1.0 : 0.6)
    }
}
```

**5. TitleCollectionView.swift:**
```swift
struct TitleCollectionView: View {
    @State private var viewModel = TitleViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                Text("🏅 칭호 도감")
                    .font(.headline)
                    .padding(.horizontal, 16)

                Text("\(viewModel.unlockedCount)/\(viewModel.titles.count)개 획득")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)

                // Grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.titles) { title in
                        TitleCard(title: title)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .onAppear {
            viewModel.loadData()
        }
    }
}
```

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 칭호 탭 클릭 시 칭호 도감 표시
- [ ] 10개 칭호 카드 그리드 표시
- [ ] 미획득 칭호 "❓" 아이콘 + "???" 표시
- [ ] 획득 칭호 컬러 아이콘 + 칭호명 표시 (Story 3.2에서 테스트)
- [ ] 획득 개수 표시 (0/10)
- [ ] 스크롤 동작 확인

### References

- [Source: epics.md#Story-3.1] 스토리 정의 및 AC
- [Source: prd.md#FR-4.1] 칭호 도감 화면 표시
- [Source: prd.md#FR-4.2] 획득 칭호는 컬러, 미획득은 회색
- [Source: architecture.md#5.2] Title 모델 정의
- [Source: ux-design-specification.md#4.3] 칭호 도감 컴포넌트 디자인
- [Source: prd.md#MVP-칭호목록] 10개 MVP 칭호

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-08: BUILD SUCCEEDED

### Completion Notes List

- ✅ Title.swift - Title 모델 + TitleCondition enum + 10개 MVP 칭호 정적 데이터
- ✅ TitleRepository.swift - Singleton 패턴, titles.json 저장/로드, unlock() 메서드
- ✅ TitleViewModel.swift - @Observable 매크로, titles/unlockedTitles/lockedTitles 프로퍼티
- ✅ TitleCard.swift - 획득(컬러 아이콘+칭호명) / 미획득(❓+???) UI
- ✅ TitleCollectionView.swift - LazyVGrid 2열 그리드, 헤더 (N/10개 획득)
- ✅ ContentView.swift - 칭호 탭에 TitleCollectionView 연결

### File List

**신규:**
- FocusBuddy/FocusBuddy/Models/Title.swift
- FocusBuddy/FocusBuddy/Services/TitleRepository.swift
- FocusBuddy/FocusBuddy/ViewModels/TitleViewModel.swift
- FocusBuddy/FocusBuddy/Views/TitleCollectionView.swift
- FocusBuddy/FocusBuddy/Views/Components/TitleCard.swift

**수정:**
- FocusBuddy/FocusBuddy/Views/ContentView.swift

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-08 | Story 3.1 생성 - 칭호 도감 UI |
| 2026-01-08 | Story 3.1 구현 완료 - 칭호 시스템 기반 구축 |
