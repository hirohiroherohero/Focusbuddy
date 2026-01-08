import SwiftUI

struct TitleUnlockPopup: View {
    let title: Title
    let onDismiss: () -> Void

    @State private var iconScale: CGFloat = 0.5
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // 반투명 배경
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture { onDismiss() }

            // 팝업 카드
            VStack(spacing: 16) {
                Text(title.icon)
                    .font(.system(size: 64))
                    .scaleEffect(iconScale)

                Text("🏅 「\(title.name)」 획득!")
                    .font(.headline)

                Text(title.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(24)
            .background(Color(NSColor.windowBackgroundColor))
            .cornerRadius(16)
            .shadow(radius: 10)
            .opacity(opacity)
        }
        .onAppear {
            // 팝 애니메이션: 확대
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                iconScale = 1.2
                opacity = 1
            }
            // 0.3초 후 원래 크기로 축소
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    iconScale = 1.0
                }
            }
        }
    }
}

#Preview("Title Unlock Popup") {
    let title = Title(
        id: "first_focus",
        name: "신입 집중러",
        icon: "🌱",
        description: "첫 세션 완료",
        condition: .sessionCount(1),
        unlockedAt: Date()
    )
    return TitleUnlockPopup(title: title) {
        print("Dismissed")
    }
    .frame(width: 320, height: 400)
}
