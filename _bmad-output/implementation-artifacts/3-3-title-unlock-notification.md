# Story 3.3: 칭호 획득 알림

Status: review

## Story

As a **사용자**,
I want **칭호를 획득하면 축하 알림을 받기를**,
So that **성취감과 즐거움을 느낄 수 있다**.

## Acceptance Criteria

1. **AC-1: 인앱 축하 팝업**
   - **Given** 칭호 조건을 달성했을 때
   - **When** 칭호가 획득되면
   - **Then** 팝업으로 "🏅 '칭호명' 획득!" 메시지가 표시된다
   - **And** 칭호 아이콘이 팝 애니메이션과 함께 나타난다

2. **AC-2: 칭호 도감 업데이트**
   - **Given** 칭호를 획득했을 때
   - **When** 알림을 확인하면
   - **Then** 칭호 도감에 해당 칭호가 컬러로 변경되어 있다

3. **AC-3: 대표 칭호 설정**
   - **Given** 획득한 칭호가 있을 때
   - **When** 칭호를 탭하면
   - **Then** 해당 칭호를 대표 칭호로 설정할 수 있다
   - **And** 대표 칭호는 앱 헤더에 표시된다

## Tasks / Subtasks

- [x] **Task 1: TitleUnlockState 상태 관리** (AC: #1)
  - [x] 1.1: TitleViewModel에 `newlyUnlockedTitle: Title?` 프로퍼티 추가
  - [x] 1.2: TitleChecker에서 획득 시 TitleViewModel에 알림
  - [x] 1.3: 팝업 표시 후 자동 해제 로직 (3초 후)

- [x] **Task 2: 축하 팝업 UI 구현** (AC: #1)
  - [x] 2.1: TitleUnlockPopup.swift 컴포넌트 생성
  - [x] 2.2: 축하 메시지 "🏅 '칭호명' 획득!" 표시
  - [x] 2.3: 칭호 아이콘 + 설명 표시
  - [x] 2.4: 반투명 오버레이 + 중앙 정렬 카드

- [x] **Task 3: 팝 애니메이션 구현** (AC: #1)
  - [x] 3.1: 칭호 아이콘 스케일 애니메이션 (0.5 → 1.2 → 1.0)
  - [x] 3.2: 페이드인 + 바운스 효과
  - [x] 3.3: 3초 후 자동 페이드아웃

- [x] **Task 4: ContentView 통합** (AC: #1, #2)
  - [x] 4.1: ContentView에 팝업 오버레이 추가
  - [x] 4.2: TitleViewModel 상태 구독
  - [x] 4.3: 팝업 닫기 시 칭호 탭으로 이동 (선택적)

- [x] **Task 5: 대표 칭호 기능 구현** (AC: #3)
  - [x] 5.1: TitleRepository에 `representativeTitle` 프로퍼티 추가
  - [x] 5.2: TitleRepository에 `setRepresentative(_:)` 메서드 추가
  - [x] 5.3: titles.json에 대표 칭호 저장
  - [x] 5.4: TitleViewModel에 대표 칭호 관련 computed property 추가

- [x] **Task 6: 대표 칭호 UI 구현** (AC: #3)
  - [x] 6.1: TitleCard에 탭 제스처 추가 (획득 칭호만)
  - [x] 6.2: 현재 대표 칭호 하이라이트 표시 (테두리 또는 배지)
  - [x] 6.3: ContentView 헤더에 대표 칭호 표시

- [x] **Task 7: 빌드 및 테스트**
  - [x] 7.1: 빌드 성공 확인
  - [x] 7.2: 테스트 모드로 칭호 획득 → 팝업 표시 확인
  - [x] 7.3: 대표 칭호 설정 및 헤더 표시 확인
  - [x] 7.4: 앱 재시작 후 대표 칭호 유지 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴 준수:**
```
TitleChecker ──notifies──► TitleViewModel ──triggers──► TitleUnlockPopup
                                         ──updates──► TitleCollectionView
```

**Singleton 패턴:**
- TitleChecker.shared (기존)
- TitleRepository.shared (기존) - 대표 칭호 저장 추가
- TitleViewModel (ContentView에서 공유 인스턴스 필요)

### Technical Requirements

**1. TitleViewModel 상태 추가:**
```swift
@Observable
class TitleViewModel {
    // 기존 프로퍼티...

    // 신규 획득 칭호 (팝업용)
    var newlyUnlockedTitle: Title?
    var showUnlockPopup: Bool = false

    // 대표 칭호
    var representativeTitle: Title? {
        guard let titleId = titleRepository.representativeTitleId else { return nil }
        return titles.first { $0.id == titleId }
    }

    func showTitleUnlock(_ title: Title) {
        newlyUnlockedTitle = title
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            showUnlockPopup = true
        }

        // 3초 후 자동 닫기
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.dismissUnlockPopup()
        }
    }

    func dismissUnlockPopup() {
        withAnimation(.easeOut(duration: 0.3)) {
            showUnlockPopup = false
        }
        newlyUnlockedTitle = nil
    }

    func setRepresentative(_ title: Title) {
        titleRepository.setRepresentative(title.id)
    }
}
```

**2. TitleUnlockPopup.swift:**
```swift
import SwiftUI

struct TitleUnlockPopup: View {
    let title: Title
    let onDismiss: () -> Void

    @State private var iconScale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // 팝업 카드
            VStack(spacing: 16) {
                Text(title.icon)
                    .font(.system(size: 64))
                    .scaleEffect(iconScale)

                Text("🏅 「\(title.name)」 획득!")
                    .font(.headline)

                Text(title.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(radius: 10)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.2
                opacity = 1
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    iconScale = 1.0
                }
            }
        }
    }
}
```

**3. TitleRepository 대표 칭호 저장:**
```swift
// TitleRepository에 추가
private(set) var representativeTitleId: String?

func setRepresentative(_ titleId: String) {
    guard unlockedTitleIds.contains(titleId) else { return }
    representativeTitleId = titleId
    persist()
}

// TitleData 수정
private struct TitleData: Codable {
    let unlockedIds: [String]
    let unlockDates: [String: Date]
    let representativeTitleId: String?  // 추가
}
```

**4. TitleChecker → TitleViewModel 연동:**
```swift
// TitleChecker.swift 수정
final class TitleChecker {
    // ...

    func checkAndUnlockTitles() {
        for title in Title.allTitles {
            guard !titleRepository.isUnlocked(title.id) else { continue }
            if evaluateCondition(title.condition) {
                titleRepository.unlock(title.id)
                notificationService.notifyTitleUnlocked(title: title)

                // 인앱 팝업 트리거 (새로 추가)
                DispatchQueue.main.async {
                    NotificationCenter.default.post(
                        name: .titleUnlocked,
                        object: title
                    )
                }
            }
        }
    }
}

// Notification 확장
extension Notification.Name {
    static let titleUnlocked = Notification.Name("titleUnlocked")
}
```

**5. ContentView 통합:**
```swift
struct ContentView: View {
    private var timerViewModel = TimerViewModel.shared
    @State private var titleViewModel = TitleViewModel()  // 공유 인스턴스
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            // 기존 VStack 내용...
            VStack(spacing: 0) {
                headerView
                Divider()
                tabContent
                // ...
            }

            // 칭호 획득 팝업 오버레이
            if titleViewModel.showUnlockPopup, let title = titleViewModel.newlyUnlockedTitle {
                TitleUnlockPopup(title: title) {
                    titleViewModel.dismissUnlockPopup()
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .titleUnlocked)) { notification in
            if let title = notification.object as? Title {
                titleViewModel.showTitleUnlock(title)
            }
        }
    }

    private var headerView: some View {
        HStack {
            Text("FocusBuddy")
                .font(.headline)
                .fontWeight(.semibold)

            // 대표 칭호 표시
            if let representativeTitle = titleViewModel.representativeTitle {
                Text(representativeTitle.icon)
                    .font(.title2)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
```

**6. TitleCard 탭 제스처:**
```swift
struct TitleCard: View {
    let title: Title
    let isRepresentative: Bool
    let onTap: (() -> Void)?

    var body: some View {
        VStack(spacing: 8) {
            Text(title.isUnlocked ? title.icon : "❓")
                .font(.system(size: 36))

            Text(title.isUnlocked ? title.name : "???")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(title.isUnlocked ? .primary : .secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRepresentative ? Color.buddyGreen : Color.clear, lineWidth: 2)
        )
        .opacity(title.isUnlocked ? 1.0 : 0.6)
        .onTapGesture {
            if title.isUnlocked {
                onTap?()
            }
        }
    }
}
```

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
└── Views/
    └── Components/
        └── TitleUnlockPopup.swift    # 칭호 획득 축하 팝업
```

**수정할 파일:**
```
FocusBuddy/FocusBuddy/
├── Services/
│   ├── TitleChecker.swift        # NotificationCenter 발송 추가
│   └── TitleRepository.swift     # 대표 칭호 저장 추가
├── ViewModels/
│   └── TitleViewModel.swift      # 팝업 상태, 대표 칭호 로직
├── Views/
│   ├── ContentView.swift         # 팝업 오버레이, 헤더 대표 칭호
│   ├── TitleCollectionView.swift # TitleCard에 탭 제스처 전달
│   └── Components/
│       └── TitleCard.swift       # 탭 제스처, 대표 칭호 표시
└── project.pbxproj              # TitleUnlockPopup.swift 추가
```

### Previous Story Intelligence

**Story 3.2에서 구현된 내용:**
- TitleChecker.shared 싱글톤 서비스
- checkAndUnlockTitles() 메서드
- macOS 알림 (NotificationService.notifyTitleUnlocked) - 이미 구현됨
- 세션 완료 시 TitleChecker 호출 (TimerViewModel.handleTimerComplete)

**Story 3.1에서 구현된 내용:**
- Title 모델 및 allTitles 정적 데이터
- TitleRepository 싱글톤 (unlock, isUnlocked, persist)
- TitleViewModel (titles, unlockedTitles, lockedTitles)
- TitleCollectionView 및 TitleCard UI

**재사용할 패턴:**
- TitleRepository의 JSON 영속화 패턴
- TitleCard의 획득/미획득 시각적 구분
- ContentView의 탭 및 오버레이 구조

### Edge Cases

1. **동시 다중 칭호 획득:** 여러 칭호 동시 획득 시 순차적으로 팝업 표시 (큐 사용)
2. **대표 칭호 삭제 방지:** 대표 칭호는 다른 칭호로 교체만 가능 (삭제 없음)
3. **앱 시작 시:** 대표 칭호 데이터 로드 및 헤더 표시
4. **미획득 칭호 탭:** 탭해도 아무 반응 없음 (획득 칭호만 대표 설정 가능)

### Animation Specifications

**팝 애니메이션:**
```swift
// 아이콘 등장
withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
    iconScale = 1.2  // 확대
}
// 0.3초 후 원래 크기로
withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
    iconScale = 1.0
}
```

**페이드아웃:**
```swift
withAnimation(.easeOut(duration: 0.3)) {
    opacity = 0
    showUnlockPopup = false
}
```

### References

- [Source: epics.md#Story-3.3] 스토리 정의 및 AC
- [Source: prd.md#FR-4.4] 조건 달성 시 칭호 획득 알림
- [Source: prd.md#FR-4.5] 대표 칭호 설정 기능
- [Source: Story-3.1] TitleRepository, TitleViewModel, TitleCard 구현
- [Source: Story-3.2] TitleChecker, NotificationService.notifyTitleUnlocked 구현

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- Build succeeded on 2026-01-08

### Completion Notes List

1. **TitleViewModel 팝업 상태 구현 완료**
   - `newlyUnlockedTitle: Title?` 프로퍼티 추가
   - `showUnlockPopup: Bool` 프로퍼티 추가
   - `showTitleUnlock(_:)` 메서드 - 팝업 표시 및 3초 후 자동 닫기
   - `dismissUnlockPopup()` 메서드 - 팝업 닫기

2. **TitleUnlockPopup.swift 생성 완료**
   - 반투명 배경 + 중앙 카드 레이아웃
   - 칭호 아이콘 + "🏅 '칭호명' 획득!" 메시지 + 설명 표시
   - 스프링 팝 애니메이션 (0.5 → 1.2 → 1.0 스케일)
   - 페이드인 효과

3. **TitleChecker NotificationCenter 연동 완료**
   - 칭호 획득 시 `.titleUnlocked` 노티피케이션 발송
   - Notification.Name 확장 추가

4. **TitleRepository 대표 칭호 기능 완료**
   - `representativeTitleId: String?` 프로퍼티 추가
   - `setRepresentative(_:)` 메서드 추가
   - TitleData에 representativeTitleId 필드 추가
   - titles.json에 대표 칭호 저장

5. **ContentView 통합 완료**
   - ZStack으로 팝업 오버레이 추가
   - NotificationCenter 구독으로 칭호 획득 이벤트 처리
   - 헤더에 대표 칭호 아이콘 표시

6. **TitleCard 대표 칭호 UI 완료**
   - `isRepresentative: Bool` 파라미터 추가
   - `onTap: (() -> Void)?` 파라미터 추가
   - 대표 칭호 초록색 테두리 하이라이트
   - 획득 칭호 탭 제스처로 대표 칭호 설정

7. **TitleCollectionView 대표 칭호 연동 완료**
   - TitleCard에 isRepresentative, onTap 전달
   - viewModel.setRepresentative(_:) 호출

### File List

**신규:**
- `FocusBuddy/FocusBuddy/Views/Components/TitleUnlockPopup.swift`

**수정:**
- `FocusBuddy/FocusBuddy/Services/TitleChecker.swift` - NotificationCenter 발송 추가
- `FocusBuddy/FocusBuddy/Services/TitleRepository.swift` - Notification.Name 확장, 대표 칭호 저장 기능 추가
- `FocusBuddy/FocusBuddy/ViewModels/TitleViewModel.swift` - 팝업 상태, 대표 칭호 로직 추가
- `FocusBuddy/FocusBuddy/Views/ContentView.swift` - 팝업 오버레이, 헤더 대표 칭호 표시
- `FocusBuddy/FocusBuddy/Views/TitleCollectionView.swift` - TitleCard에 탭 제스처 전달
- `FocusBuddy/FocusBuddy/Views/Components/TitleCard.swift` - 탭 제스처, 대표 칭호 표시
- `FocusBuddy/FocusBuddy.xcodeproj/project.pbxproj` - TitleUnlockPopup.swift 추가

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-08 | Story 3.3 생성 - 칭호 획득 알림 및 대표 칭호 설정 |
| 2026-01-08 | 구현 완료 - 인앱 팝업, 애니메이션, 대표 칭호 기능 |
