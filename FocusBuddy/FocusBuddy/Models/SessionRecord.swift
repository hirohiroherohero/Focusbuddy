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

    // MARK: - Computed Properties

    /// 날짜만 추출 (잔디 캘린더용)
    var date: Date {
        Calendar.current.startOfDay(for: startTime)
    }

    /// 집중 시간 (분)
    var durationMinutes: Int {
        Int(endTime.timeIntervalSince(startTime) / 60)
    }
}
