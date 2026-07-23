import SwiftUI

struct ContentView: View {
    @ObservedObject private var store = ShortcutStore.shared

    @State private var showingAddSheet = false
    @State private var editingShortcut: AppShortcut?

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            shortcutList
            Divider()
            SettingsSection()
                .padding(16)
        }
        .frame(width: 540, height: 620)
        .sheet(isPresented: $showingAddSheet) {
            ShortcutEditorView(editing: nil)
        }
        .sheet(item: $editingShortcut) { shortcut in
            ShortcutEditorView(editing: shortcut)
        }
    }

    private var header: some View {
        HStack {
            Text(L("shortcuts.title"))
                .font(.headline)
            Spacer()
            Button {
                showingAddSheet = true
            } label: {
                Label(L("shortcuts.add"), systemImage: "plus")
            }
        }
        .padding(16)
    }

    @ViewBuilder
    private var shortcutList: some View {
        if store.shortcuts.isEmpty {
            VStack(spacing: 8) {
                Image(systemName: "keyboard")
                    .font(.system(size: 36))
                    .foregroundStyle(.tertiary)
                Text(L("shortcuts.empty"))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            List {
                ForEach(store.shortcuts) { shortcut in
                    ShortcutRow(
                        shortcut: shortcut,
                        registrationFailed: store.failedShortcutIDs.contains(shortcut.id),
                        onEdit: { editingShortcut = shortcut },
                        onDelete: { store.remove(shortcut) }
                    )
                }
            }
            .listStyle(.inset)
        }
    }
}

private struct ShortcutRow: View {
    let shortcut: AppShortcut
    let registrationFailed: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(nsImage: NSWorkspace.shared.icon(forFile: shortcut.appPath))
                .resizable()
                .frame(width: 28, height: 28)

            Text(shortcut.appName)

            if registrationFailed {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.yellow)
                    .help(L("alert.registerFailed"))
            }

            Spacer()

            Text(shortcut.displayString)
                .font(.system(.body, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))

            Button {
                onEdit()
            } label: {
                Image(systemName: "pencil")
            }
            .buttonStyle(.borderless)
            .help(L("shortcuts.edit"))

            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.borderless)
            .help(L("shortcuts.delete"))
        }
        .padding(.vertical, 3)
    }
}
