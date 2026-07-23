import SwiftUI
import AppKit
import UniformTypeIdentifiers

/// Sheet for adding a new shortcut or editing an existing one.
struct ShortcutEditorView: View {
    let editing: AppShortcut?

    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var store = ShortcutStore.shared

    @State private var apps: [InstalledApp] = []
    @State private var isScanning = true
    @State private var searchText = ""
    @State private var selectedApp: InstalledApp?
    @State private var capture: KeyCapture?

    private var filteredApps: [InstalledApp] {
        guard !searchText.isEmpty else { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
    }

    private var comboTaken: Bool {
        guard let selectedApp, let capture else { return false }
        return store.isComboTaken(makeShortcut(app: selectedApp, capture: capture))
    }

    var body: some View {
        VStack(spacing: 0) {
            Text(editing == nil ? L("add.title") : L("edit.title"))
                .font(.headline)
                .padding(.top, 16)

            appPicker
                .padding(16)

            Divider()

            recorderSection
                .padding(16)

            Divider()

            footer
                .padding(16)
        }
        .frame(width: 440, height: 520)
        .task { loadApps() }
    }

    // MARK: - App picker

    private var appPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(L("add.selectApp"))
                .font(.subheadline.weight(.semibold))

            TextField(L("add.search"), text: $searchText)
                .textFieldStyle(.roundedBorder)

            Group {
                if isScanning {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 2) {
                            ForEach(filteredApps) { app in
                                appRow(app)
                            }
                        }
                    }
                }
            }
            .frame(height: 220)
            .background(.quaternary.opacity(0.5), in: RoundedRectangle(cornerRadius: 8))

            Button(L("add.chooseOther")) { chooseOtherApp() }
                .controlSize(.small)
        }
    }

    private func appRow(_ app: InstalledApp) -> some View {
        Button {
            selectedApp = app
        } label: {
            HStack(spacing: 8) {
                Image(nsImage: NSWorkspace.shared.icon(forFile: app.path))
                    .resizable()
                    .frame(width: 22, height: 22)
                Text(app.name)
                    .lineLimit(1)
                Spacer()
                if selectedApp == app {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.accentColor)
                }
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
        .buttonStyle(.plain)
        .background(
            selectedApp == app ? Color.accentColor.opacity(0.15) : .clear,
            in: RoundedRectangle(cornerRadius: 6)
        )
    }

    // MARK: - Key recorder

    private var recorderSection: some View {
        HStack {
            Text(L("add.shortcut"))
                .font(.subheadline.weight(.semibold))
            Spacer()
            KeyRecorderButton(capture: $capture)
        }
    }

    // MARK: - Footer

    private var footer: some View {
        HStack {
            if comboTaken {
                Label(L("add.duplicate"), systemImage: "exclamationmark.triangle")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
            Spacer()
            Button(L("add.cancel")) { dismiss() }
                .keyboardShortcut(.cancelAction)
            Button(L("add.save")) { save() }
                .keyboardShortcut(.defaultAction)
                .disabled(selectedApp == nil || capture == nil || comboTaken)
        }
    }

    // MARK: - Actions

    private func loadApps() {
        Task.detached(priority: .userInitiated) {
            let scanned = AppScanner.scan()
            await MainActor.run {
                apps = scanned
                isScanning = false
                if let editing {
                    selectedApp = scanned.first { $0.bundleID == editing.bundleID }
                        ?? AppScanner.installedApp(at: editing.appPath)
                    capture = KeyCapture(keyCode: editing.keyCode,
                                         carbonModifiers: editing.carbonModifiers,
                                         display: editing.keyDisplay)
                }
            }
        }
    }

    private func chooseOtherApp() {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = [.application]
        panel.directoryURL = URL(fileURLWithPath: "/Applications")
        panel.allowsMultipleSelection = false
        guard panel.runModal() == .OK,
              let url = panel.url,
              let app = AppScanner.installedApp(at: url.path)
        else { return }
        selectedApp = app
        if !apps.contains(app) {
            apps.insert(app, at: 0)
        }
    }

    private func makeShortcut(app: InstalledApp, capture: KeyCapture) -> AppShortcut {
        AppShortcut(id: editing?.id ?? UUID(),
                    appName: app.name,
                    bundleID: app.bundleID,
                    appPath: app.path,
                    keyCode: capture.keyCode,
                    carbonModifiers: capture.carbonModifiers,
                    keyDisplay: capture.display)
    }

    private func save() {
        guard let selectedApp, let capture else { return }
        let shortcut = makeShortcut(app: selectedApp, capture: capture)
        if editing == nil {
            store.add(shortcut)
        } else {
            store.update(shortcut)
        }
        dismiss()
    }
}
