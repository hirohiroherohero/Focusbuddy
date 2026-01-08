import Foundation

@Observable
class TitleViewModel {
    private let titleRepository = TitleRepository.shared

    // MARK: - Computed Properties

    var titles: [Title] {
        Title.allTitles.map { title in
            var t = title
            t.unlockedAt = titleRepository.unlockDates[title.id]
            return t
        }
    }

    var unlockedTitles: [Title] {
        titles.filter { $0.isUnlocked }
    }

    var lockedTitles: [Title] {
        titles.filter { !$0.isUnlocked }
    }

    var unlockedCount: Int {
        unlockedTitles.count
    }

    var totalCount: Int {
        titles.count
    }

    // MARK: - Public Methods

    func loadData() {
        titleRepository.load()
    }
}
