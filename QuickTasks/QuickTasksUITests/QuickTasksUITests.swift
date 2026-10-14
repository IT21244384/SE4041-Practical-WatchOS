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

    private var countText: String { element("completedCount").label }

    /// Scrolls the list until the element can be tapped.
    private func reveal(_ target: XCUIElement) {
        XCTAssertTrue(target.waitForExistence(timeout: 10))
        var attempts = 0
        while !target.isHittable && attempts < 6 {
            app.swipeUp()
            attempts += 1
        }
        attempts = 0
        while !target.isHittable && attempts < 6 {
            app.swipeDown()
            attempts += 1
        }
    }

    private func scrollToTop() {
        for _ in 0..<4 { app.swipeDown() }
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
        for title in ["Morning Walk", "Drink Water", "Read Notes", "Call Home"] {
            XCTAssertTrue(element("toggle-\(title)").waitForExistence(timeout: 10), title)
        }
        XCTAssertEqual(countText, "2 / 4 Completed")
        XCTAssertEqual(element("progressPercent").label, "50% Complete")
        requestScreenshot("01-Main-Screen")

        // Test 2 - tapping an incomplete task completes it
        toggle("Drink Water")
        XCTAssertEqual(element("toggle-Drink Water").value as? String, "Completed")
        XCTAssertEqual(countText, "3 / 4 Completed")

        // Test 3 - tapping it again returns it to incomplete
        toggle("Drink Water")
        XCTAssertEqual(element("toggle-Drink Water").value as? String, "Pending")
        XCTAssertEqual(countText, "2 / 4 Completed")

        // Test 4 - completing several tasks updates the count
        toggle("Drink Water")
        toggle("Read Notes")
        XCTAssertEqual(countText, "4 / 4 Completed")
        XCTAssertEqual(element("progressPercent").label, "100% Complete")
        toggle("Read Notes")
        XCTAssertEqual(countText, "3 / 4 Completed")
        XCTAssertEqual(element("progressPercent").label, "75% Complete")
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
        XCTAssertEqual(element("progressPercent").label, "0% Complete")
    }
}
