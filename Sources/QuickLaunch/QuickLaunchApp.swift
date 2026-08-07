import SwiftUI

@main
struct QuickLaunchApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @AppStorage(PrefKey.showMenuBarIcon) private var showMenuBarIcon = true

    var body: some Scene {
        Window(L("app.name"), id: "main") {
            ContentView()
                .frame(width: 540, height: 620)
        }
        .windowStyle(.titleBar)
        .windowResizability(.contentSize)

        MenuBarExtra(isInserted: $showMenuBarIcon) {
            MenuBarContent()
        } label: {
            Image(systemName: "command.square.fill")
        }
    }
}
