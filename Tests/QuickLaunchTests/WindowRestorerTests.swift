import XCTest
@testable import QuickLaunch

final class WindowRestorerTests: XCTestCase {
    func testUsesOpenWindowInsteadOfRestoringOtherMinimizedWindows() {
        let windows = [
            state(minimized: true, focused: true, main: true),
            state(minimized: false),
            state(minimized: true),
        ]
        XCTAssertEqual(WindowRestorer.preferredIndex(in: windows), 1)
    }

    func testChoosesMainWindowWhenAllWindowsAreMinimized() {
        let windows = [state(minimized: true), state(minimized: true, main: true)]
        XCTAssertEqual(WindowRestorer.preferredIndex(in: windows), 1)
    }

    func testFocusedWindowTakesPriorityOverMainWindow() {
        let windows = [state(minimized: false, main: true), state(minimized: false, focused: true)]
        XCTAssertEqual(WindowRestorer.preferredIndex(in: windows), 1)
    }

    func testSingleMinimizedWindowCanBeRestoredWithoutFocusMetadata() {
        XCTAssertEqual(WindowRestorer.preferredIndex(in: [state(minimized: true)]), 0)
    }

    func testMissingOrUnsupportedWindowsAreNotSelected() {
        XCTAssertNil(WindowRestorer.preferredIndex(in: []))
        XCTAssertNil(WindowRestorer.preferredIndex(in: [state(minimized: nil, main: true)]))
    }

    private func state(minimized: Bool?, focused: Bool = false,
                       main: Bool = false) -> WindowRestorer.WindowState {
        .init(isMinimized: minimized, isFocused: focused, isMain: main)
    }
}
