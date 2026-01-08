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

    // MARK: - Private Methods

    private func createDirectoryIfNeeded() {
        let directory = titlesURL.deletingLastPathComponent()
        if !fileManager.fileExists(atPath: directory.path) {
            try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
        }
    }

    // MARK: - Public Methods

    func unlock(_ titleId: String) {
        guard !unlockedTitleIds.contains(titleId) else { return }
        unlockedTitleIds.insert(titleId)
        unlockDates[titleId] = Date()
        persist()
    }

    func isUnlocked(_ titleId: String) -> Bool {
        unlockedTitleIds.contains(titleId)
    }

    func load() {
        guard let data = try? Data(contentsOf: titlesURL),
              let decoded = try? JSONDecoder.iso8601.decode(TitleData.self, from: data) else {
            return
        }
        unlockedTitleIds = Set(decoded.unlockedIds)
        unlockDates = decoded.unlockDates
    }

    // MARK: - Persistence

    private func persist() {
        let data = TitleData(
            unlockedIds: Array(unlockedTitleIds),
            unlockDates: unlockDates
        )
        guard let encoded = try? JSONEncoder.iso8601.encode(data) else { return }
        try? encoded.write(to: titlesURL)
    }
}

// MARK: - TitleData (Internal Storage Model)

private struct TitleData: Codable {
    let unlockedIds: [String]
    let unlockDates: [String: Date]
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
