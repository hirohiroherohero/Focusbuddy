import SwiftUI

struct TimerView: View {
    @Bindable var viewModel: TimerViewModel

    var body: some View {
        VStack(spacing: 20) {
            // 응원 메시지 토스트
            if viewModel.showMessage {
                messageToast
                    .transition(.opacity)
            }

            // 상태 텍스트 + 루프 카운터
            if viewModel.state.isFocusing {
                focusingStatusText
                loopCounter
            } else if viewModel.state.isResting {
                restingStatusText
                loopCounter
            }

            // 타이머 디스플레이
            timerDisplay

            // 루프 선택 (대기 상태일 때만)
            if viewModel.state == .idle {
                loopSelector
            }

            // 진행 바 (집중 중 또는 휴식 중)
            if viewModel.state.isFocusing {
                focusProgressBar
            } else if viewModel.state.isResting {
                restProgressBar
            }

            // 액션 버튼 (대기 또는 집중 중일 때만)
            if !viewModel.state.isResting {
                actionButton
            }
        }
        .padding(.vertical, 20)
        .animation(.easeInOut(duration: 0.3), value: viewModel.showMessage)
    }

    // MARK: - Subviews

    private var messageToast: some View {
        Text(viewModel.currentMessage)
            .font(.system(size: 16))
            .foregroundColor(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.black.opacity(0.75))
            .cornerRadius(8)
    }

    private var focusingStatusText: some View {
        Text("🔥 집중 중!")
            .font(.headline)
            .foregroundColor(.focusRed)
    }

    private var restingStatusText: some View {
        Text("💤 휴식 중~")
            .font(.headline)
            .foregroundColor(.restBlue)
    }

    private var loopCounter: some View {
        Text("\(viewModel.completedLoops + 1)/\(viewModel.targetLoops) 세트")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }

    private var loopSelector: some View {
        HStack {
            Text("세트 수")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Spacer()

            Stepper("\(viewModel.targetLoops)회", value: $viewModel.targetLoops, in: 1...10)
                .labelsHidden()

            Text("\(viewModel.targetLoops)회")
                .font(.subheadline)
                .monospacedDigit()
        }
        .padding(.horizontal, 40)
    }

    private var timerDisplay: some View {
        Text(viewModel.displayTime)
            .font(.system(size: 48, weight: .bold, design: .monospaced))
            .foregroundColor(timerColor)
    }

    private var timerColor: Color {
        if viewModel.state.isFocusing {
            return .focusRed
        } else if viewModel.state.isResting {
            return .restBlue
        } else {
            return .secondary
        }
    }

    private var focusProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                // 진행률
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.focusRed)
                    .frame(width: geometry.size.width * viewModel.progress, height: 8)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
    }

    private var restProgressBar: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 배경
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 8)

                // 진행률
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.restBlue)
                    .frame(width: geometry.size.width * viewModel.restProgress, height: 8)
            }
        }
        .frame(height: 8)
        .padding(.horizontal, 20)
    }

    private var actionButton: some View {
        Group {
            if viewModel.state.isFocusing {
                giveUpButton
            } else {
                startButton
            }
        }
    }

    private var startButton: some View {
        VStack(spacing: 8) {
            Button(action: {
                viewModel.startFocus()
            }) {
                Label("집중 시작", systemImage: "target")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.buddyGreen)
                    .cornerRadius(8)
            }
            .buttonStyle(.plain)

            // 테스트용 5초 버튼
            Button(action: {
                viewModel.startTestFocus()
            }) {
                Text("🧪 테스트 (5초)")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(4)
            }
            .buttonStyle(.plain)
        }
    }

    private var giveUpButton: some View {
        Button(action: {
            viewModel.giveUp()
        }) {
            Text("😅 포기")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Color Extension

extension Color {
    static let focusRed = Color(red: 248/255, green: 113/255, blue: 113/255)
    static let buddyGreen = Color(red: 74/255, green: 222/255, blue: 128/255)
    static let restBlue = Color(red: 96/255, green: 165/255, blue: 250/255)

    // Grass Calendar Colors
    static let grass0 = Color(hex: "#EBEDF0")  // 0회 - 빈 칸
    static let grass1 = Color(hex: "#9BE9A8")  // 1회 - 연한 초록
    static let grass2 = Color(hex: "#40C463")  // 2회 - 중간 초록
    static let grass3 = Color(hex: "#30A14E")  // 3회+ - 진한 초록

    static func grassColor(for count: Int) -> Color {
        switch count {
        case 0: return .grass0
        case 1: return .grass1
        case 2: return .grass2
        default: return .grass3
        }
    }

    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255.0
        let g = Double((int >> 8) & 0xFF) / 255.0
        let b = Double(int & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    TimerView(viewModel: TimerViewModel.shared)
        .frame(width: 320, height: 300)
}
