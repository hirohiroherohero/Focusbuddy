import SwiftUI

struct GrassCell: View {
    let sessionCount: Int
    let isToday: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(Color.grassColor(for: sessionCount))
            .frame(width: 10, height: 10)
            .overlay(
                Group {
                    if isToday {
                        RoundedRectangle(cornerRadius: 2)
                            .stroke(Color.buddyGreen, lineWidth: 1)
                    }
                }
            )
    }
}

#Preview {
    HStack(spacing: 4) {
        GrassCell(sessionCount: 0, isToday: false)
        GrassCell(sessionCount: 1, isToday: false)
        GrassCell(sessionCount: 2, isToday: false)
        GrassCell(sessionCount: 3, isToday: false)
        GrassCell(sessionCount: 0, isToday: true)
    }
    .padding()
}
