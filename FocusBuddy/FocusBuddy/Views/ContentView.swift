import SwiftUI

struct ContentView: View {
    private var timerViewModel = TimerViewModel.shared
    @State private var titleViewModel = TitleViewModel()
    @State private var selectedTab = 0

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                // Header
                headerView

                Divider()

                // Tab Content
                tabContent
                    .frame(maxHeight: .infinity)

                Divider()

                // Tab Bar
                tabBar
            }

            // 칭호 획득 팝업 오버레이
            if titleViewModel.showUnlockPopup, let title = titleViewModel.newlyUnlockedTitle {
                TitleUnlockPopup(title: title) {
                    titleViewModel.dismissUnlockPopup()
                }
            }
        }
        .frame(width: 320, height: 400)
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
        .background(Color(NSColor.windowBackgroundColor))
    }

    @ViewBuilder
    private var tabContent: some View {
        switch selectedTab {
        case 0:
            TimerView(viewModel: timerViewModel)
                .transition(.opacity.combined(with: .move(edge: .leading)))
        case 1:
            GrassCalendarView()
                .transition(.opacity.combined(with: .move(edge: .trailing)))
        case 2:
            TitleCollectionView(viewModel: titleViewModel)
                .transition(.opacity)
        case 3:
            SettingsView()
                .transition(.opacity)
        default:
            TimerView(viewModel: timerViewModel)
        }
    }

    private func placeholderView(title: String, message: String) -> some View {
        VStack(spacing: 12) {
            Text(title)
                .font(.title2)
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            TabButton(icon: "house.fill", label: "홈", tag: 0, selectedTab: $selectedTab)
            TabButton(icon: "calendar", label: "잔디", tag: 1, selectedTab: $selectedTab)
            TabButton(icon: "trophy.fill", label: "칭호", tag: 2, selectedTab: $selectedTab)
            TabButton(icon: "gearshape.fill", label: "설정", tag: 3, selectedTab: $selectedTab)
        }
        .padding(.vertical, 8)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

// MARK: - TabButton

struct TabButton: View {
    let icon: String
    let label: String
    let tag: Int
    @Binding var selectedTab: Int

    var body: some View {
        Button(action: {
            withAnimation(.easeInOut(duration: 0.2)) {
                selectedTab = tag
            }
        }) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 18))
                Text(label)
                    .font(.caption2)
            }
            .foregroundColor(selectedTab == tag ? .buddyGreen : .secondary)
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ContentView()
}
