import AppKit
import SwiftUI
import Combine

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem?
    var popover: NSPopover?
    private var timerObservation: AnyCancellable?

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupStatusItem()
        setupPopover()
        observeTimer()
    }

    private func setupStatusItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "target", accessibilityDescription: "FocusBuddy")
            button.action = #selector(togglePopover(_:))
            button.target = self
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 320, height: 400)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(rootView: ContentView())
    }

    private func observeTimer() {
        // 0.5초마다 타이머 상태 확인하여 메뉴바 업데이트
        timerObservation = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateMenuBarTitle()
            }
    }

    private func updateMenuBarTitle() {
        let viewModel = TimerViewModel.shared

        guard let button = statusItem?.button else { return }

        if viewModel.state.isFocusing {
            button.image = NSImage(systemSymbolName: "flame.fill", accessibilityDescription: "집중 중")
            button.title = " \(viewModel.displayTime)"
        } else if viewModel.state.isResting {
            button.image = NSImage(systemSymbolName: "moon.zzz.fill", accessibilityDescription: "휴식 중")
            button.title = " \(viewModel.displayTime)"
        } else {
            button.image = NSImage(systemSymbolName: "target", accessibilityDescription: "FocusBuddy")
            button.title = ""
        }
    }

    @objc func togglePopover(_ sender: AnyObject?) {
        guard let button = statusItem?.button else { return }

        if popover?.isShown == true {
            popover?.performClose(sender)
        } else {
            popover?.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            popover?.contentViewController?.view.window?.makeKey()
        }
    }
}
