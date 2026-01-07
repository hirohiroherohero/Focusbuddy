import SwiftUI

struct ContentView: View {
    private var timerViewModel = TimerViewModel.shared

    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView

            Divider()

            // Main Content Area - Timer
            TimerView(viewModel: timerViewModel)

            Spacer()
        }
        .frame(width: 320, height: 400)
    }

    private var headerView: some View {
        HStack {
            Text("FocusBuddy")
                .font(.headline)
                .fontWeight(.semibold)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(NSColor.windowBackgroundColor))
    }
}

#Preview {
    ContentView()
}
