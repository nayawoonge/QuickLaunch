import SwiftUI
import ServiceManagement

struct SettingsSection: View {
    @AppStorage(PrefKey.showMenuBarIcon) private var showMenuBarIcon = true
    @AppStorage(PrefKey.hideDockIcon) private var hideDockIcon = false
    @AppStorage(PrefKey.restoreMinimizedWindows) private var restoreMinimizedWindows = false

    @State private var launchAtLogin = LoginItemManager.isEnabled
    @State private var loginItemError: String?
    @State private var accessibilityGranted = WindowRestorer.hasPermission

    var body: some View {
        GroupBox(L("settings.title")) {
            VStack(alignment: .leading, spacing: 10) {
                Toggle(L("settings.launchAtLogin"), isOn: $launchAtLogin)
                    .onChange(of: launchAtLogin) { _, newValue in
                        setLaunchAtLogin(newValue)
                    }

                if let loginItemError {
                    Text(loginItemError)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                Toggle(L("settings.showMenuBar"), isOn: $showMenuBarIcon)

                Toggle(L("settings.hideDock"), isOn: $hideDockIcon)
                    .onChange(of: hideDockIcon) { _, _ in
                        AppDelegate.shared.applyActivationPolicy()
                    }

                Toggle(L("settings.restoreMinimized"), isOn: $restoreMinimizedWindows)
                    .onChange(of: restoreMinimizedWindows) { _, _ in
                        accessibilityGranted = WindowRestorer.hasPermission
                    }

                if restoreMinimizedWindows {
                    Text(L(accessibilityGranted
                           ? "settings.restoreMinimizedHelp" : "settings.accessibilityRequired"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                    if !accessibilityGranted {
                        Button(L("settings.allowAccessibility")) {
                            WindowRestorer.requestPermission()
                            accessibilityGranted = WindowRestorer.hasPermission
                        }
                        .controlSize(.small)
                    }
                }

                if !showMenuBarIcon && hideDockIcon {
                    Label(L("settings.hiddenWarning"), systemImage: "info.circle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(8)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .onAppear {
            launchAtLogin = LoginItemManager.isEnabled
            accessibilityGranted = WindowRestorer.hasPermission
        }
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            accessibilityGranted = WindowRestorer.hasPermission
        }
    }

    private func setLaunchAtLogin(_ enabled: Bool) {
        guard enabled != LoginItemManager.isEnabled else { return }
        do {
            try LoginItemManager.setEnabled(enabled)
            loginItemError = nil
        } catch {
            loginItemError = L("settings.loginError")
            launchAtLogin = LoginItemManager.isEnabled
        }
    }
}
