import SwiftUI

struct TitleCollectionView: View {
    @Bindable var viewModel: TitleViewModel

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    headerView

                    // Grid
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach(viewModel.titles) { title in
                            TitleCard(
                                title: title,
                                isRepresentative: viewModel.representativeTitle?.id == title.id,
                                onTap: {
                                    viewModel.setRepresentative(title)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 16)
            }

            // 대표 칭호 설정 토스트
            if viewModel.showRepresentativeToast {
                VStack {
                    Spacer()
                    Text("대표 칭호로 설정되었습니다!")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.buddyGreen)
                        .cornerRadius(20)
                        .shadow(radius: 4)
                        .padding(.bottom, 16)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
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

            Text("💡 획득한 칭호를 탭하여 대표 칭호로 설정하세요")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    TitleCollectionView(viewModel: TitleViewModel())
        .frame(width: 320, height: 400)
}
