# Story 1.1: 메뉴바 앱 기본 설정

Status: review

## Story

As a **사용자**,
I want **메뉴바에서 FocusBuddy 아이콘을 클릭하면 팝오버가 열리기를**,
So that **집중 앱에 쉽게 접근할 수 있다**.

## Acceptance Criteria

1. **AC-1: 메뉴바 아이콘 표시**
   - **Given** 앱이 실행되었을 때
   - **When** 시스템 메뉴바를 확인하면
   - **Then** FocusBuddy 아이콘(🎯)이 표시된다

2. **AC-2: 팝오버 열기**
   - **Given** 메뉴바에 아이콘이 표시된 상태에서
   - **When** 아이콘을 클릭하면
   - **Then** 320x400px 크기의 팝오버가 나타난다

3. **AC-3: 팝오버 닫기**
   - **Given** 팝오버가 열린 상태에서
   - **When** 팝오버 외부를 클릭하면
   - **Then** 팝오버가 닫힌다

## Tasks / Subtasks

- [x] **Task 1: Xcode 프로젝트 설정** (AC: 전체)
  - [x] 1.1: Xcode 프로젝트 생성 (macOS App, SwiftUI)
  - [x] 1.2: 번들 ID 설정: `com.focusbuddy.app`
  - [x] 1.3: Deployment Target: macOS 13.0
  - [x] 1.4: 프로젝트 폴더 구조 생성 (Models/, ViewModels/, Views/, Services/, Resources/)

- [x] **Task 2: AppDelegate 및 메뉴바 설정** (AC: #1, #2)
  - [x] 2.1: AppDelegate.swift 생성 - NSStatusItem 설정
  - [x] 2.2: NSPopover 생성 및 설정
  - [x] 2.3: 메뉴바 아이콘 표시 (🎯 또는 SF Symbol)
  - [x] 2.4: 아이콘 클릭 시 팝오버 토글 구현

- [x] **Task 3: 팝오버 콘텐츠 설정** (AC: #2)
  - [x] 3.1: ContentView.swift 생성 - 팝오버 메인 컨테이너
  - [x] 3.2: 팝오버 크기 설정 (320x400)
  - [x] 3.3: 기본 UI 레이아웃 (헤더, 콘텐츠 영역)

- [x] **Task 4: 팝오버 외부 클릭 닫기** (AC: #3)
  - [x] 4.1: NSPopover behavior 설정 (.transient)
  - [x] 4.2: 외부 클릭 시 자동 닫힘 확인

- [x] **Task 5: App Lifecycle 설정**
  - [x] 5.1: LSUIElement = true 설정 (Dock 아이콘 숨김)
  - [x] 5.2: @main 진입점 설정

## Dev Notes

### Architecture Compliance

**MVVM 패턴 필수 준수:**
```
View (SwiftUI) ──observe──► ViewModel (@Observable) ──uses──► Model + Services
```

**이 스토리에서는 아직 ViewModel이 필요 없음** - 단순 UI 설정만 포함.

### Technical Requirements

**Swift 5.9+ 필수:**
- `@Observable` 매크로 사용 준비 (다음 스토리부터)
- async/await 패턴 사용 가능

**SwiftUI + AppKit 하이브리드:**
```swift
// AppDelegate.swift - AppKit
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // NSStatusItem 설정
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        // NSPopover 설정
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient  // 외부 클릭 시 닫힘
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }
}
```

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/
├── FocusBuddyApp.swift           # @main 진입점
├── AppDelegate.swift             # 메뉴바 설정 (AppKit)
├── Info.plist                    # LSUIElement = true
│
├── Models/                       # (빈 폴더 - 준비)
├── ViewModels/                   # (빈 폴더 - 준비)
├── Views/
│   └── ContentView.swift         # 팝오버 메인 뷰
├── Services/                     # (빈 폴더 - 준비)
└── Resources/
    └── Assets.xcassets           # 앱 아이콘
```

### UX Design Compliance

**팝오버 크기:**
- 너비: 320px
- 높이: 400px (최소), 500px (최대)

**메뉴바 아이콘:**
- 대기 상태: 🎯 (회색 타겟) 또는 SF Symbol `target`
- 크기: 22x22 @1x, 44x44 @2x

**컬러:**
- 다크모드/라이트모드 자동 전환 (시스템 설정 따름)

### Key Implementation Details

**1. Info.plist 설정:**
```xml
<key>LSUIElement</key>
<true/>
```
→ Dock에 아이콘 표시 안 함 (메뉴바 앱)

**2. FocusBuddyApp.swift:**
```swift
import SwiftUI

@main
struct FocusBuddyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
```

**3. 아이콘 클릭 토글:**
```swift
@objc func togglePopover(_ sender: AnyObject?) {
    if let button = statusItem?.button {
        if popover?.isShown == true {
            popover?.performClose(sender)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
}
```

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 앱 실행 시 메뉴바에 아이콘 표시
- [ ] 아이콘 클릭 시 팝오버 열림
- [ ] 팝오버 외부 클릭 시 닫힘
- [ ] Dock에 아이콘 없음
- [ ] 다크모드/라이트모드 전환 시 정상 동작

### Project Structure Notes

**폴더 구조 준비:**
- Models/, ViewModels/, Services/ 폴더는 빈 상태로 생성
- 향후 스토리에서 파일 추가 예정

**네이밍 컨벤션:**
- Swift API Design Guidelines 준수
- 파일명 = 클래스/구조체명

### References

- [Source: architecture.md#ADR-001] SwiftUI + AppKit 하이브리드 결정
- [Source: architecture.md#4.1] 프로젝트 구조
- [Source: ux-design-specification.md#3] 팝오버 크기 및 구조
- [Source: prd.md#FR-1] 메뉴바 앱 요구사항
- [Source: epics.md#Story-1.1] 스토리 정의

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-07: XcodeGen으로 프로젝트 생성 성공
- 2026-01-07: xcodebuild 빌드 성공 (BUILD SUCCEEDED)

### Completion Notes List

- ✅ Xcode 프로젝트 생성 (XcodeGen 사용)
- ✅ 번들 ID: com.focusbuddy.app
- ✅ Deployment Target: macOS 13.0
- ✅ MVVM 폴더 구조 생성 (Models/, ViewModels/, Views/, Services/, Resources/)
- ✅ AppDelegate.swift - NSStatusItem + NSPopover 구현
- ✅ 메뉴바 아이콘: SF Symbol "target" 사용
- ✅ 팝오버 크기: 320x400px
- ✅ 팝오버 behavior: .transient (외부 클릭 시 닫힘)
- ✅ LSUIElement = true (Dock 아이콘 숨김)
- ✅ ContentView.swift - 기본 UI 레이아웃 (헤더 + 타이머 placeholder)

### File List

**신규 생성:**
- FocusBuddy/project.yml
- FocusBuddy/FocusBuddy/FocusBuddyApp.swift
- FocusBuddy/FocusBuddy/AppDelegate.swift
- FocusBuddy/FocusBuddy/Info.plist
- FocusBuddy/FocusBuddy/Views/ContentView.swift
- FocusBuddy/FocusBuddy/Resources/Assets.xcassets/Contents.json
- FocusBuddy/FocusBuddy/Resources/Assets.xcassets/AppIcon.appiconset/Contents.json
- FocusBuddy/FocusBuddy/Models/ (빈 폴더)
- FocusBuddy/FocusBuddy/ViewModels/ (빈 폴더)
- FocusBuddy/FocusBuddy/Services/ (빈 폴더)

**자동 생성 (XcodeGen):**
- FocusBuddy/FocusBuddy.xcodeproj/

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-07 | Story 1.1 구현 완료 - 메뉴바 앱 기본 설정 |
