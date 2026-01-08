import SwiftUI

struct TitleCard: View {
    let title: Title
    var isRepresentative: Bool = false
    var onTap: (() -> Void)? = nil

    var body: some View {
        VStack(spacing: 8) {
            // Icon
            Text(title.isUnlocked ? title.icon : "❓")
                .font(.system(size: 36))

            // Name
            Text(title.isUnlocked ? title.name : "???")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(title.isUnlocked ? .primary : .secondary)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isRepresentative ? Color.buddyGreen : Color.clear, lineWidth: 2)
        )
        .opacity(title.isUnlocked ? 1.0 : 0.6)
        .onTapGesture {
            if title.isUnlocked {
                onTap?()
            }
        }
    }
}

#Preview("Unlocked") {
    let title = Title(
        id: "first_focus",
        name: "신입 집중러",
        icon: "🌱",
        description: "첫 세션 완료",
        condition: .sessionCount(1),
        unlockedAt: Date()
    )
    return TitleCard(title: title)
        .frame(width: 140)
        .padding()
}

#Preview("Locked") {
    let title = Title(
        id: "first_focus",
        name: "신입 집중러",
        icon: "🌱",
        description: "첫 세션 완료",
        condition: .sessionCount(1),
        unlockedAt: nil
    )
    return TitleCard(title: title)
        .frame(width: 140)
        .padding()
}
