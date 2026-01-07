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

    // MARK: - Private Methods

    private func createDirectoryIfNeeded() {
        let directory = sessionsURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Public Methods

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

    // MARK: - Persistence

    private func persist() {
        guard let data = try? JSONEncoder.iso8601.encode(sessions) else { return }
        try? data.write(to: sessionsURL)
    }
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
