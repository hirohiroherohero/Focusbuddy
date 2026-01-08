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
    private(set) var hasGivenUp: Bool = false

    private var flagsURL: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let focusBuddy = appSupport.appendingPathComponent("FocusBuddy", isDirectory: true)
        return focusBuddy.appendingPathComponent("flags.json")
    }

    private init() {
        createDirectoryIfNeeded()
        load()
        loadFlags()
    }

    // MARK: - Private Methods

    private func createDirectoryIfNeeded() {
        let directory = sessionsURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Public Methods

    func markGiveUp() {
        hasGivenUp = true
        persistFlags()
    }

    func save(_ session: SessionRecord) {
        sessions.append(session)
        persist()
    }

    func load() {
        guard let data = try? Data(contentsOf: sessionsURL),
              let decoded = try? JSONDecoder.iso8601.decode([SessionRecord].self, from: data) else {
            return
        }
        sessions = decoded
    }

    /// 완료된 총 세션 수
    var completedSessionCount: Int {
        sessions.filter { $0.completed }.count
    }

    /// 현재 연속 집중일 (스트릭)
    var currentStreak: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        // 날짜별 세션 존재 여부 계산
        var daysWithSessions: Set<Date> = []
        for session in sessions where session.completed {
            let day = calendar.startOfDay(for: session.startTime)
            daysWithSessions.insert(day)
        }

        // 오늘부터 거꾸로 연속 일수 계산
        var checkDate = today
        // 오늘 세션이 없으면 어제부터 시작
        if !daysWithSessions.contains(today) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            checkDate = yesterday
        }

        var streakCount = 0
        while daysWithSessions.contains(checkDate) {
            streakCount += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: checkDate) else { break }
            checkDate = previousDay
        }

        return streakCount
    }

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder.iso8601.encode(sessions) else { return }
        try? data.write(to: sessionsURL)
    }

    private func loadFlags() {
        guard let data = try? Data(contentsOf: flagsURL),
              let decoded = try? JSONDecoder().decode(FlagsData.self, from: data) else {
            return
        }
        hasGivenUp = decoded.hasGivenUp
    }

    private func persistFlags() {
        let data = FlagsData(hasGivenUp: hasGivenUp)
        guard let encoded = try? JSONEncoder().encode(data) else { return }
        try? encoded.write(to: flagsURL)
    }
}

// MARK: - FlagsData (Internal Storage Model)

private struct FlagsData: Codable {
    let hasGivenUp: Bool
}

// MARK: - JSON Encoder/Decoder Extensions

private extension JSONEncoder {
    static let iso8601: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        return encoder
    }()
}

private extension JSONDecoder {
    static let iso8601: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}
