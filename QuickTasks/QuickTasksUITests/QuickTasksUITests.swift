import XCTest

// UI tests for the testing section (Tests 1-5; Test 6 runs this suite on two watch sizes).
// At key moments the test asks the Mac running the Simulator to take a screenshot
// with `xcrun simctl io screenshot` (see .github/workflows/watchos.yml).
final class QuickTasksUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Helpers

    private func element(_ identifier: String) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }

    /// watchOS lists only create the rows that are on screen, so scroll until the element
    /// exists and can be tapped - first downwards through the list, then back up.
    private func reveal(_ target: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        if target.waitForExistence(timeout: 2) && target.isHittable { return }
        // Turn the Digital Crown in small steps (a swipe flings the whole list on this small screen)
        for _ in 0..<15 {
            XCUIDevice.shared.rotateDigitalCrown(delta: 0.15, velocity: .slow)
            if target.exists && target.isHittable { return }
        }
        for _ in 0..<30 {
            XCUIDevice.shared.rotateDigitalCrown(delta: -0.15, velocity: .slow)
            if target.exists && target.isHittable { return }
        }
        print("UI HIERARCHY:\n\(app.debugDescription)")
        XCTFail("Could not scroll to \(target)", file: file, line: line)
    }

    private func scrollToTop() {
        reveal(element("completedCount"))
    }

    /// Reads the completion count (scrolling back to the top of the list where it lives).
    private var countText: String {
        let label = element("completedCount")
        reveal(label)
        return label.label
    }

    private var percentText: String {
        let label = element("progressPercent")
        reveal(label)
        return label.label
    }

    private func toggleValue(_ title: String) -> String? {
        let button = element("toggle-\(title)")
        reveal(button)
        return button.value as? String
    }

    private func toggle(_ title: String) {
        let button = element("toggle-\(title)")
        reveal(button)
        button.tap()
    }

    private func openDetail(_ title: String) {
        let link = element("detail-\(title)")
        reveal(link)
        link.tap()
        XCTAssertTrue(element("detailStatus").waitForExistence(timeout: 5))
    }

    private func goBack() {
        let back = app.navigationBars.buttons.firstMatch
        if back.exists {
            back.tap()
        } else {
            app.swipeRight()
        }
        XCTAssertTrue(element("completedCount").waitForExistence(timeout: 5))
    }

    /// Asks the host Mac to screenshot the Simulator and waits until the file exists.
    private func requestScreenshot(_ name: String) {
        guard let directory = ProcessInfo.processInfo.environment["SCREENSHOT_DIR"] else { return }
        Thread.sleep(forTimeInterval: 1.0)   // let animations settle

        let folder = URL(fileURLWithPath: directory)
        let request = folder.appendingPathComponent("request-\(name)")
        let result = folder.appendingPathComponent("\(name).png")
        try? Data().write(to: request)

        let deadline = Date().addingTimeInterval(30)
        while !FileManager.default.fileExists(atPath: result.path) && Date() < deadline {
            Thread.sleep(forTimeInterval: 0.5)
        }
    }

    // MARK: - Tests

    func test1TasksToggleCountAndDetails() {
        // Test 1 - all four tasks appear, starting at 2 / 4
        XCTAssertTrue(element("completedCount").waitForExistence(timeout: 10))
        for title in ["Morning Walk", "Drink Water", "Read Notes", "Call Home"] {
            reveal(element("toggle-\(title)"))
        }
        XCTAssertEqual(countText, "2 / 4 Completed")
        scrollToTop()
        XCTAssertEqual(percentText, "50% Complete")
        requestScreenshot("01-Main-Screen")

        // Test 2 - tapping an incomplete task completes it
        toggle("Drink Water")
        XCTAssertEqual(toggleValue("Drink Water"), "Completed")
        XCTAssertEqual(countText, "3 / 4 Completed")

        // Test 3 - tapping it again returns it to incomplete
        toggle("Drink Water")
        XCTAssertEqual(toggleValue("Drink Water"), "Pending")
        XCTAssertEqual(countText, "2 / 4 Completed")

        // Test 4 - completing several tasks updates the count
        toggle("Drink Water")
        toggle("Read Notes")
        XCTAssertEqual(countText, "4 / 4 Completed")
        XCTAssertEqual(percentText, "100% Complete")
        toggle("Read Notes")
        XCTAssertEqual(countText, "3 / 4 Completed")
        XCTAssertEqual(percentText, "75% Complete")
        scrollToTop()
        requestScreenshot("02-Completed-Tasks")

        // Test 5 - the detail screen shows the right task, and reflects a status change
        openDetail("Drink Water")
        XCTAssertTrue(app.staticTexts["Drink Water"].exists)
        XCTAssertEqual(element("detailStatus").label, "Completed")
        requestScreenshot("03-Task-Detail")
        goBack()

        toggle("Drink Water")
        openDetail("Drink Water")
        XCTAssertEqual(element("detailStatus").label, "Pending")
        requestScreenshot("04-Task-Detail-Pending")
        goBack()
    }

    // Part G - Reset marks every task as incomplete
    func test2ResetTasks() {
        XCTAssertTrue(element("completedCount").waitForExistence(timeout: 10))
        XCTAssertEqual(countText, "2 / 4 Completed")

        let reset = element("resetButton")
        reveal(reset)
        reset.tap()

        XCTAssertEqual(countText, "0 / 4 Completed")
        XCTAssertEqual(percentText, "0% Complete")
    }
}
