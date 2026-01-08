import SwiftUI

struct SettingsView: View {
    @State private var launchAtLogin: Bool = SettingsRepository.shared.launchAtLogin

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("설정")
                    .font(.headline)
                    .padding(.horizontal, 16)

                // Settings List
                VStack(spacing: 0) {
                    // Launch at Login
                    settingRow(
                        icon: "power",
                        title: "로그인 시 자동 시작",
                        subtitle: "Mac 시작 시 FocusBuddy 자동 실행"
                    ) {
                        Toggle("", isOn: $launchAtLogin)
                            .toggleStyle(.switch)
                            .labelsHidden()
                            .onChange(of: launchAtLogin) { _, newValue in
                                SettingsRepository.shared.launchAtLogin = newValue
                            }
                    }

                    Divider()
                        .padding(.leading, 52)

                    // App Info
                    settingRow(
                        icon: "info.circle",
                        title: "버전",
                        subtitle: "FocusBuddy v1.0.0"
                    ) {
                        EmptyView()
                    }
                }
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(10)
                .padding(.horizontal, 16)

                Spacer()

                // Footer
                VStack(spacing: 4) {
                    Text("FocusBuddy")
                        .font(.caption)
                        .fontWeight(.medium)
                    Text("Made with 💚")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.bottom, 16)
            }
            .padding(.vertical, 16)
        }
    }

    // MARK: - Subviews

    private func settingRow<Content: View>(
        icon: String,
        title: String,
        subtitle: String,
        @ViewBuilder trailing: () -> Content
    ) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.buddyGreen)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()

            trailing()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
    }
}

#Preview {
    SettingsView()
        .frame(width: 320, height: 400)
}
