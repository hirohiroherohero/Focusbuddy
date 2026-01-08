import SwiftUI

struct GrassCalendarView: View {
    @State private var viewModel = CalendarViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 연도 헤더
            yearHeader

            // 잔디 캘린더 그리드
            ScrollView(.horizontal, showsIndicators: false) {
                calendarGrid
                    .padding(.horizontal, 16)
            }

            // 범례
            legendView

            Divider()
                .padding(.horizontal, 16)

            // 통계
            statsView
        }
        .padding(.vertical, 16)
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Subviews

    private var yearHeader: some View {
        Text(yearString)
            .font(.headline)
            .padding(.horizontal, 16)
    }

    private var yearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년"
        return formatter.string(from: Date())
    }

    private var calendarGrid: some View {
        // 7행 (일~토) x 52열 (주)
        LazyHGrid(
            rows: Array(repeating: GridItem(.fixed(10), spacing: 2), count: 7),
            spacing: 2
        ) {
            ForEach(viewModel.flattenedDays, id: \.self) { date in
                GrassCell(
                    sessionCount: viewModel.sessionCount(for: date),
                    isToday: viewModel.isToday(date)
                )
            }
        }
    }

    private var legendView: some View {
        HStack(spacing: 4) {
            Spacer()

            Text("적음")
                .font(.caption2)
                .foregroundColor(.secondary)

            ForEach(0..<4) { level in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color.grassColor(for: level))
                    .frame(width: 10, height: 10)
            }

            Text("많음")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
    }

    private var statsView: some View {
        HStack {
            // 연속일
            Label("\(viewModel.streak)일 연속", systemImage: "flame.fill")
                .foregroundColor(.orange)

            Spacer()

            // 총 시간
            Label(formatTotalTime(viewModel.totalFocusMinutes), systemImage: "clock.fill")
                .foregroundColor(.buddyGreen)
        }
        .font(.subheadline)
        .padding(.horizontal, 16)
    }

    private func formatTotalTime(_ minutes: Int) -> String {
        if minutes < 60 {
            return "총 \(minutes)분"
        } else {
            let hours = minutes / 60
            let mins = minutes % 60
            if mins == 0 {
                return "총 \(hours)시간"
            } else {
                return "총 \(hours)시간 \(mins)분"
            }
        }
    }
}

#Preview {
    GrassCalendarView()
        .frame(width: 320, height: 200)
}
