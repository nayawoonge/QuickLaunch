import SwiftUI
import AppKit

struct KeyCapture: Equatable {
    let keyCode: UInt16
    let carbonModifiers: UInt32
    let display: String

    var displayString: String {
        AppShortcut(appName: "", bundleID: "", appPath: "",
                    keyCode: keyCode, carbonModifiers: carbonModifiers,
                    keyDisplay: display).displayString
    }
}

/// Click → records the next key combination pressed. ESC cancels.
struct KeyRecorderButton: View {
    @Binding var capture: KeyCapture?

    @State private var isRecording = false
    @State private var monitor: Any?

    var body: some View {
        Button {
            isRecording ? stopRecording() : startRecording()
        } label: {
            Text(label)
                .font(.system(.body, design: .monospaced))
                .frame(minWidth: 160)
        }
        .onDisappear { stopRecording() }
    }

    private var label: String {
        if isRecording { return L("recorder.press") }
        return capture?.displayString ?? L("recorder.click")
    }

    private func startRecording() {
        isRecording = true
        // Release global hotkeys so the combo being recorded reaches us
        // even if it is already assigned.
        ShortcutStore.shared.suspendHotKeys()

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { event in
            let modifiers = KeyCodeHelper.carbonModifiers(from: event.modifierFlags)

            // Bare ESC cancels recording.
            if event.keyCode == 53, modifiers == 0 {
                stopRecording()
                return nil
            }

            let isFunctionKey = KeyCodeHelper.functionKeyCodes.contains(event.keyCode)
            // Require at least one modifier, except for F-keys.
            guard modifiers != 0 || isFunctionKey else { return nil }

            let display = KeyCodeHelper.displayString(
                keyCode: event.keyCode,
                characters: event.charactersIgnoringModifiers
            )
            capture = KeyCapture(keyCode: event.keyCode,
                                 carbonModifiers: modifiers,
                                 display: display)
            stopRecording()
            return nil
        }
    }

    private func stopRecording() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
        monitor = nil
        isRecording = false
        ShortcutStore.shared.registerAll()
    }
}
