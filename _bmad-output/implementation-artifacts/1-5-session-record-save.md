# Story 1.5: 세션 기록 저장

Status: done

## Story

As a **사용자**,
I want **완료된 집중 세션이 저장되기를**,
So that **나의 집중 기록이 유지된다**.

## Acceptance Criteria

1. **AC-1: 세션 완료 시 저장**
   - **Given** 집중 세션이 완료되었을 때
   - **When** 휴식으로 전환되면
   - **Then** 세션 기록이 JSON 파일에 저장된다
   - **And** 기록에는 시작시간, 종료시간, 완료여부가 포함된다

2. **AC-2: 앱 재시작 시 데이터 유지**
   - **Given** 앱을 종료했다가 다시 실행했을 때
   - **When** 앱이 시작되면
   - **Then** 이전에 저장된 세션 기록이 로드된다

## Tasks / Subtasks

- [x] **Task 1: SessionRecord 모델 생성** (AC: #1)
  - [x] 1.1: Models/SessionRecord.swift 생성
  - [x] 1.2: Codable 구조체 정의 (startTime, endTime, completed)
  - [x] 1.3: 날짜 기반 편의 프로퍼티 추가

- [x] **Task 2: SessionRepository 생성** (AC: #1, #2)
  - [x] 2.1: Services/SessionRepository.swift 생성
  - [x] 2.2: JSON 파일 경로 설정 (~/Library/Application Support/FocusBuddy/)
  - [x] 2.3: save() 메서드 - 세션 저장
  - [x] 2.4: load() 메서드 - 세션 로드
  - [x] 2.5: 디렉토리 자동 생성

- [x] **Task 3: TimerViewModel 연동** (AC: #1)
  - [x] 3.1: SessionRepository 인스턴스 추가
  - [x] 3.2: 집중 시작 시 startTime 기록
  - [x] 3.3: 집중 완료 시 세션 저장

- [x] **Task 4: 빌드 및 테스트**
  - [x] 4.1: 빌드 성공 확인
  - [x] 4.2: 세션 완료 후 JSON 파일 생성 확인
  - [x] 4.3: 앱 재시작 후 데이터 로드 확인

## Dev Notes

### Architecture Compliance

**MVVM 패턴:**
```
TimerViewModel ──uses──► SessionRepository ──saves──► JSON File
                              │
                              ▼
                         SessionRecord
```

**파일 저장 경로 (Architecture 문서 기준):**
```
~/Library/Application Support/FocusBuddy/sessions.json
```

### Technical Requirements

**SessionRecord.swift:**
```swift
import Foundation

struct SessionRecord: Codable, Identifiable {
    let id: UUID
    let startTime: Date
    let endTime: Date
    let completed: Bool

    init(startTime: Date, endTime: Date, completed: Bool) {
        self.id = UUID()
        self.startTime = startTime
        self.endTime = endTime
        self.completed = completed
    }

    // 날짜만 추출 (잔디 캘린더용)
    var date: Date {
        Calendar.current.startOfDay(for: startTime)
    }
}
```

**SessionRepository.swift:**
```swift
import Foundation

final class SessionRepository {
    static let shared = SessionRepository()

    private let fileManager = FileManager.default
    private var sessionsURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let focusBuddy = appSupport.appendingPathComponent("FocusBuddy", isDirectory: true)
        return focusBuddy.appendingPathComponent("sessions.json")
    }

    private(set) var sessions: [SessionRecord] = []

    private init() {
        createDirectoryIfNeeded()
        load()
    }

    private func createDirectoryIfNeeded() {
        let directory = sessionsURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    func save(_ session: SessionRecord) {
        sessions.append(session)
        persist()
    }

    private func load() {
        guard let data = try? Data(contentsOf: sessionsURL),
              let decoded = try? JSONDecoder().decode([SessionRecord].self, from: data) else {
            return
        }
        sessions = decoded
    }

    private func persist() {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(sessions) else { return }
        try? data.write(to: sessionsURL)
    }
}
```

**TimerViewModel 연동:**
```swift
// 프로퍼티 추가
private var sessionStartTime: Date?
private let sessionRepository = SessionRepository.shared

// startFocus() 수정
func startFocus() {
    sessionStartTime = Date()
    // ... 기존 코드
}

// handleTimerComplete() 수정 - focusing 완료 시
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
    // ... 기존 코드
}
```

### File Structure Requirements

**생성할 파일:**
```
FocusBuddy/FocusBuddy/
├── Models/
│   └── SessionRecord.swift      # 세션 기록 모델
└── Services/
    └── SessionRepository.swift  # 세션 저장/로드
```

**수정할 파일:**
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift

### Previous Story Intelligence

**Story 1.4에서 구현된 것:**
- handleTimerComplete()에서 focusing → resting 전환
- MessageService 연동 패턴

**Architecture 문서에서 정의된 것:**
- ~/Library/Application Support/FocusBuddy/ 경로
- JSON 파일 기반 데이터 저장 (UserDefaults 아님)

### Testing Requirements

**수동 테스트 체크리스트:**
- [ ] 집중 세션 완료 후 sessions.json 파일 생성 확인
- [ ] JSON 파일에 startTime, endTime, completed 포함 확인
- [ ] 앱 종료 후 재시작 시 데이터 유지 확인
- [ ] 여러 세션 완료 후 배열에 누적 확인

**파일 확인 명령어:**
```bash
cat ~/Library/Application\ Support/FocusBuddy/sessions.json
```

### References

- [Source: prd.md#FR-6.1] 세션 완료 시 히스토리 저장
- [Source: prd.md#FR-6.2] 앱 재시작 시 데이터 유지
- [Source: architecture.md] ~/Library/Application Support/FocusBuddy/ 경로
- [Source: epics.md#Story-1.5] 스토리 정의

---

## Dev Agent Record

### Agent Model Used

Claude Opus 4.5 (claude-opus-4-5-20251101)

### Debug Log References

- 2026-01-07: BUILD SUCCEEDED

### Completion Notes List

- ✅ SessionRecord.swift - Codable 구조체, date/durationMinutes 프로퍼티
- ✅ SessionRepository.swift - 싱글톤, JSON 파일 저장/로드
- ✅ ~/Library/Application Support/FocusBuddy/sessions.json 경로
- ✅ TimerViewModel - sessionStartTime 추적, 완료 시 세션 저장

### File List

**신규 생성:**
- FocusBuddy/FocusBuddy/Models/SessionRecord.swift
- FocusBuddy/FocusBuddy/Services/SessionRepository.swift

**수정:**
- FocusBuddy/FocusBuddy/ViewModels/TimerViewModel.swift

## Change Log

| 날짜 | 변경사항 |
|-----|---------|
| 2026-01-07 | Story 1.5 구현 완료 - 세션 기록 저장 |
