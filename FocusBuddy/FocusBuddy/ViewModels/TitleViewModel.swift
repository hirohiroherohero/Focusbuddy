import Foundation
import SwiftUI

@Observable
class TitleViewModel {
    private let titleRepository = TitleRepository.shared

    // MARK: - Popup State

    var newlyUnlockedTitle: Title?
    var showUnlockPopup: Bool = false
    var showRepresentativeToast: Bool = false
    private var toastDismissWorkItem: DispatchWorkItem?

    // MARK: - Representative Title State

    private(set) var representativeTitleId: String?
    private(set) var representativeTitle: Title?

    init() {
        representativeTitleId = titleRepository.representativeTitleId
        representativeTitle = findTitle(by: representativeTitleId)
    }

    private func findTitle(by titleId: String?) -> Title? {
        guard let titleId = titleId else { return nil }
        return Title.allTitles.first { $0.id == titleId }
    }

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
        representativeTitleId = titleRepository.representativeTitleId
        representativeTitle = findTitle(by: representativeTitleId)
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
        representativeTitleId = title.id
        representativeTitle = title

        // 이전 타이머 취소
        toastDismissWorkItem?.cancel()

        // 토스트 표시
        withAnimation(.easeInOut(duration: 0.2)) {
            showRepresentativeToast = true
        }

        // 새 타이머 생성
        let workItem = DispatchWorkItem { [weak self] in
            withAnimation(.easeOut(duration: 0.2)) {
                self?.showRepresentativeToast = false
            }
        }
        toastDismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: workItem)
    }
}
