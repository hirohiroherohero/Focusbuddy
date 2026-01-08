import SwiftUI

struct TitleCollectionView: View {
    @State private var viewModel = TitleViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                headerView

                // Grid
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(viewModel.titles) { title in
                        TitleCard(title: title)
                    }
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 16)
        }
        .onAppear {
            viewModel.loadData()
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("칭호 도감")
                .font(.headline)

            Text("\(viewModel.unlockedCount)/\(viewModel.totalCount)개 획득")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TitleCollectionView()
        .frame(width: 320, height: 400)
}
