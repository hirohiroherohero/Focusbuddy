import Foundation
import ServiceManagement

final class SettingsRepository {
    static let shared = SettingsRepository()

    private let defaults = UserDefaults.standard

    // MARK: - Keys

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
    }

    // MARK: - Properties

    var launchAtLogin: Bool {
        get { defaults.bool(forKey: Keys.launchAtLogin) }
        set {
            defaults.set(newValue, forKey: Keys.launchAtLogin)
            updateLaunchAtLogin(newValue)
        }
    }

    private init() {
        // 앱 시작 시 현재 상태 동기화
        syncLaunchAtLoginState()
    }

    // MARK: - Launch at Login

    private func updateLaunchAtLogin(_ enabled: Bool) {
        if #available(macOS 13.0, *) {
            do {
                if enabled {
                    try SMAppService.mainApp.register()
                } else {
                    try SMAppService.mainApp.unregister()
                }
            } catch {
                print("Failed to update launch at login: \(error)")
            }
        }
    }

    private func syncLaunchAtLoginState() {
        if #available(macOS 13.0, *) {
            let currentStatus = SMAppService.mainApp.status
            let isRegistered = currentStatus == .enabled
            if defaults.bool(forKey: Keys.launchAtLogin) != isRegistered {
                defaults.set(isRegistered, forKey: Keys.launchAtLogin)
            }
        }
    }
}
