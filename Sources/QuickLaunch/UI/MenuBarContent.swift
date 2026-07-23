import SwiftUI

struct MenuBarContent: View {
    @ObservedObject private var store = ShortcutStore.shared

    var body: some View {
        if store.shortcuts.isEmpty {
            Text(L("menubar.noShortcuts"))
        } else {
            ForEach(store.shortcuts) { shortcut in
                Button("\(shortcut.appName)  \(shortcut.displayString)") {
                    store.launch(shortcut)
                }
            }
        }

        Divider()

        Button(L("menubar.open")) {
            AppDelegate.shared.showMainWindow()
        }

        Divider()

        Button(L("menubar.quit")) {
            NSApp.terminate(nil)
        }
    }
}
