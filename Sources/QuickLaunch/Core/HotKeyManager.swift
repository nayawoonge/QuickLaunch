import AppKit
import Carbon.HIToolbox

/// Registers system-wide hotkeys via Carbon `RegisterEventHotKey`.
/// No Accessibility permission is required for this API.
final class HotKeyManager {
    static let shared = HotKeyManager()

    private var hotKeyRefs: [UInt32: EventHotKeyRef] = [:]
    private var handlers: [UInt32: () -> Void] = [:]
    private var nextID: UInt32 = 1
    private var eventHandlerInstalled = false

    private init() {}

    /// Returns `false` if the system refused the registration
    /// (e.g. the combo is reserved or already taken by another hotkey).
    @discardableResult
    func register(keyCode: UInt32, carbonModifiers: UInt32, handler: @escaping () -> Void) -> Bool {
        installEventHandlerIfNeeded()

        let id = nextID
        nextID += 1
        let hotKeyID = EventHotKeyID(signature: OSType(0x514C_4348) /* 'QLCH' */, id: id)
        var ref: EventHotKeyRef?
        let status = RegisterEventHotKey(keyCode, carbonModifiers, hotKeyID,
                                         GetApplicationEventTarget(), 0, &ref)
        guard status == noErr, let ref else { return false }

        hotKeyRefs[id] = ref
        handlers[id] = handler
        return true
    }

    func unregisterAll() {
        for (_, ref) in hotKeyRefs {
            UnregisterEventHotKey(ref)
        }
        hotKeyRefs.removeAll()
        handlers.removeAll()
    }

    fileprivate func handle(hotKeyID: UInt32) {
        handlers[hotKeyID]?()
    }

    private func installEventHandlerIfNeeded() {
        guard !eventHandlerInstalled else { return }
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard),
                                      eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, _ in
            guard let event else { return noErr }
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event,
                              EventParamName(kEventParamDirectObject),
                              EventParamType(typeEventHotKeyID),
                              nil,
                              MemoryLayout<EventHotKeyID>.size,
                              nil,
                              &hotKeyID)
            HotKeyManager.shared.handle(hotKeyID: hotKeyID.id)
            return noErr
        }, 1, &eventType, nil, nil)
        eventHandlerInstalled = true
    }
}
