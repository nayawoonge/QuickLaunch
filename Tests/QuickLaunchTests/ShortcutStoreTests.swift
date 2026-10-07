import Foundation
import XCTest
@testable import QuickLaunch

final class ShortcutStoreTests: XCTestCase {
    private var defaults: UserDefaults!
    private var suiteName: String!
    private var manager: TestHotKeyManager!
    private var store: ShortcutStore!

    override func setUp() {
        super.setUp()
        suiteName = "QuickLaunchTests.\(UUID().uuidString)"
        defaults = UserDefaults(suiteName: suiteName)!
        manager = TestHotKeyManager()
        store = ShortcutStore(defaults: defaults, hotKeyManager: manager, observeWorkspace: false)
        store.add(shortcut())
    }

    override func tearDown() {
        store = nil
        defaults.removePersistentDomain(forName: suiteName)
        defaults = nil
        manager = nil
        super.tearDown()
    }

    func testSupportedClientsReleaseRegistrationsAndRestoreOnExit() {
        XCTAssertTrue(store.pauseInRemoteApps)
        for bundleID in ["com.microsoft.rdc.macos", "com.parallels.desktop.console",
                         "com.parallels.vm", "com.parallels.macvm", "com.vmware.fusion"] {
            store.updateFrontmostApplication(bundleID: bundleID)
            XCTAssertTrue(store.isPausedForRemoteApp, bundleID)
            XCTAssertTrue(manager.registeredKeys.isEmpty, bundleID)
            XCTAssertTrue(store.failedShortcutIDs.isEmpty)

            store.updateFrontmostApplication(bundleID: "com.apple.finder")
            XCTAssertFalse(store.areHotKeysPaused)
            XCTAssertEqual(manager.registeredKeys, [17])
        }
    }

    func testOrdinaryAppSwitchesDoNotReregisterOrMatchSimilarNames() {
        let initialRegistrations = manager.registrationAttempts
        let initialUnregistrations = manager.unregistrationCalls
        for bundleID in ["com.apple.Safari", "com.apple.Terminal", "com.microsoft.rdc.macos.unrelated", nil] {
            store.updateFrontmostApplication(bundleID: bundleID)
            XCTAssertFalse(store.areHotKeysPaused)
        }
        XCTAssertEqual(manager.registrationAttempts, initialRegistrations)
        XCTAssertEqual(manager.unregistrationCalls, initialUnregistrations)
    }

    func testAutomaticPauseCanBeDisabledAndItsPreferencePersists() {
        store.updateFrontmostApplication(bundleID: "com.microsoft.rdc.macos")
        store.pauseInRemoteApps = false
        XCTAssertFalse(store.areHotKeysPaused)
        XCTAssertEqual(manager.registeredKeys, [17])

        let reloaded = ShortcutStore(defaults: defaults, hotKeyManager: TestHotKeyManager(), observeWorkspace: false)
        XCTAssertFalse(reloaded.pauseInRemoteApps)
        XCTAssertEqual(reloaded.shortcuts, store.shortcuts)

        store.pauseInRemoteApps = true
        XCTAssertTrue(store.areHotKeysPaused)
        XCTAssertTrue(manager.registeredKeys.isEmpty)
    }

    func testManualAndRemotePausesDoNotOverrideEachOther() {
        store.isManuallyPaused = true
        store.updateFrontmostApplication(bundleID: "com.microsoft.rdc.macos")
        store.isManuallyPaused = false
        XCTAssertTrue(store.areHotKeysPaused)
        XCTAssertTrue(manager.registeredKeys.isEmpty)

        store.isManuallyPaused = true
        store.updateFrontmostApplication(bundleID: "com.apple.finder")
        XCTAssertTrue(manager.registeredKeys.isEmpty)
        store.isManuallyPaused = false
        XCTAssertEqual(manager.registeredKeys, [17])
    }

    func testManualPauseIsNotPersistedAcrossLaunches() {
        store.isManuallyPaused = true
        let reloaded = ShortcutStore(defaults: defaults, hotKeyManager: TestHotKeyManager(), observeWorkspace: false)
        XCTAssertFalse(reloaded.isManuallyPaused)
        XCTAssertFalse(reloaded.areHotKeysPaused)
    }

    func testEditingShortcutsWhilePausedDoesNotRegisterKeys() {
        store.updateFrontmostApplication(bundleID: "com.parallels.vm")
        let second = shortcut(keyCode: 18)
        store.add(second)
        store.remove(store.shortcuts[0])
        var edited = second
        edited.keyCode = 19
        store.update(edited)
        XCTAssertTrue(manager.registeredKeys.isEmpty)

        store.updateFrontmostApplication(bundleID: "com.apple.finder")
        XCTAssertEqual(manager.registeredKeys, [19])
    }

    func testRecordingPausesSurviveFocusChangesAndShortcutEdits() {
        let recording = store.beginRecordingHotKey()
        store.add(shortcut(keyCode: 18))
        store.updateFrontmostApplication(bundleID: "com.parallels.vm")
        store.updateFrontmostApplication(bundleID: "com.apple.finder")
        XCTAssertTrue(manager.registeredKeys.isEmpty)

        store.endRecordingHotKey(recording)
        XCTAssertEqual(manager.registeredKeys, [17, 18])
    }

    func testFinishingRecordingDoesNotOverrideRemoteOrManualPause() {
        let recording = store.beginRecordingHotKey()
        store.updateFrontmostApplication(bundleID: "com.microsoft.rdc.macos")
        store.endRecordingHotKey(recording)
        XCTAssertTrue(manager.registeredKeys.isEmpty)

        store.isManuallyPaused = true
        let nextRecording = store.beginRecordingHotKey()
        store.updateFrontmostApplication(bundleID: "com.apple.finder")
        store.endRecordingHotKey(nextRecording)
        XCTAssertTrue(manager.registeredKeys.isEmpty)
        store.isManuallyPaused = false
        XCTAssertEqual(manager.registeredKeys, [17])
    }

    func testOnlyFinalRecordingSessionCanResumeKeys() {
        let first = store.beginRecordingHotKey()
        let second = store.beginRecordingHotKey()
        store.endRecordingHotKey(first)
        store.endRecordingHotKey(first) // A repeated view disappearance is harmless.
        store.endRecordingHotKey(UUID())
        XCTAssertTrue(manager.registeredKeys.isEmpty)
        store.endRecordingHotKey(second)
        XCTAssertEqual(manager.registeredKeys, [17])
    }

    func testDisablingAutomaticPauseDoesNotOverrideRecorderOrManualPause() {
        store.updateFrontmostApplication(bundleID: "com.microsoft.rdc.macos")
        let recording = store.beginRecordingHotKey()
        store.isManuallyPaused = true
        store.pauseInRemoteApps = false
        store.endRecordingHotKey(recording)
        XCTAssertTrue(manager.registeredKeys.isEmpty)
        store.isManuallyPaused = false
        XCTAssertEqual(manager.registeredKeys, [17])
    }

    func testRegistrationFailuresAreClearedWhilePausedAndRetriedOnResume() {
        manager.acceptsRegistrations = false
        store.registerAll()
        XCTAssertEqual(store.failedShortcutIDs, Set(store.shortcuts.map(\.id)))
        store.isManuallyPaused = true
        XCTAssertTrue(store.failedShortcutIDs.isEmpty)
        store.isManuallyPaused = false
        XCTAssertEqual(store.failedShortcutIDs, Set(store.shortcuts.map(\.id)))

        store.isManuallyPaused = true
        manager.acceptsRegistrations = true
        store.isManuallyPaused = false
        XCTAssertTrue(store.failedShortcutIDs.isEmpty)
        XCTAssertEqual(manager.registeredKeys, [17])
    }

    private func shortcut(keyCode: UInt16 = 17) -> AppShortcut {
        AppShortcut(appName: "Test App", bundleID: "test.app", appPath: "/test.app",
                    keyCode: keyCode, carbonModifiers: 6144, keyDisplay: "T")
    }
}

private final class TestHotKeyManager: HotKeyRegistering {
    var registeredKeys: [UInt32] = []
    var registrationAttempts = 0
    var unregistrationCalls = 0
    var acceptsRegistrations = true

    func register(keyCode: UInt32, carbonModifiers: UInt32, handler: @escaping () -> Void) -> Bool {
        registrationAttempts += 1
        guard acceptsRegistrations else { return false }
        registeredKeys.append(keyCode)
        return true
    }

    func unregisterAll() {
        unregistrationCalls += 1
        registeredKeys.removeAll()
    }
}
