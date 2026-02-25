import XCTest

final class ReflectionFlowUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    // MARK: - Home Screen

    func testHomeScreenShowsTitle() {
        XCTAssertTrue(app.navigationBars["5-4-3-2-1"].exists)
    }

    func testNewReflectionButtonExists() {
        let button = app.buttons["New Reflection"]
        XCTAssertTrue(button.exists)
    }

    // MARK: - New Reflection Flow

    func testNewReflectionFlowShowsFirstStep() {
        app.buttons["New Reflection"].tap()

        // Should see the first step - "See"
        let seeText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS 'see'"))
        XCTAssertTrue(seeText.waitForExistence(timeout: 3))
    }

    func testCancelFlowReturnsToHome() {
        app.buttons["New Reflection"].tap()

        // Wait for the flow to appear
        let cancelButton = app.buttons["Cancel"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))

        cancelButton.tap()

        // Should return to home
        let homeTitle = app.navigationBars["5-4-3-2-1"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 3))
    }

    func testManualInputFlowCompletesFiveSteps() {
        app.buttons["New Reflection"].tap()

        // Complete all 5 steps using manual text input
        let senseNames = ["see", "touch", "hear", "smell", "taste"]

        for (index, sense) in senseNames.enumerated() {
            // Wait for the step to appear
            let stepText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", sense))
            XCTAssertTrue(stepText.waitForExistence(timeout: 5), "Step \(index + 1) (\(sense)) should appear")

            // Switch to Type mode
            let typeSegment = app.buttons["Type"]
            if typeSegment.waitForExistence(timeout: 2) {
                typeSegment.tap()
            }

            // Find and fill the text field
            let textField = app.textViews.firstMatch
            if textField.waitForExistence(timeout: 2) {
                textField.tap()
                textField.typeText("Testing \(sense) entry \(index + 1)")
            }

            // Tap Next button
            let nextButton = app.buttons["Next"]
            if nextButton.waitForExistence(timeout: 2) {
                nextButton.tap()
            }
        }

        // After all 5 steps, should see completion view
        let completeText = app.staticTexts["Reflection Complete"]
        XCTAssertTrue(completeText.waitForExistence(timeout: 5), "Should show completion screen")

        // Tap Save & Close
        let saveButton = app.buttons["Save & Close"]
        XCTAssertTrue(saveButton.exists, "Save button should exist")
        saveButton.tap()

        // Should return to home with the new reflection visible
        let homeTitle = app.navigationBars["5-4-3-2-1"]
        XCTAssertTrue(homeTitle.waitForExistence(timeout: 5), "Should return to home screen")
    }

    func testVoiceAndTypeModeToggle() {
        app.buttons["New Reflection"].tap()

        // Should default to Voice mode
        let voiceSegment = app.buttons["Voice"]
        let typeSegment = app.buttons["Type"]

        XCTAssertTrue(voiceSegment.waitForExistence(timeout: 3))
        XCTAssertTrue(typeSegment.exists)

        // Switch to Type
        typeSegment.tap()

        // Text field should appear
        let textField = app.textViews.firstMatch
        XCTAssertTrue(textField.waitForExistence(timeout: 2))

        // Switch back to Voice
        voiceSegment.tap()

        // Record button should appear
        let recordButton = app.buttons["Start recording"]
        XCTAssertTrue(recordButton.waitForExistence(timeout: 2))
    }

    // MARK: - Detail View

    func testTapReflectionOpensDetail() {
        // First create a reflection via the manual flow
        createReflectionViaManualInput()

        // Now tap the first reflection in the list
        let firstCell = app.cells.firstMatch
        if firstCell.waitForExistence(timeout: 3) {
            firstCell.tap()

            // Should see the detail view with "Reflection" in the nav bar
            let navBar = app.navigationBars["Reflection"]
            XCTAssertTrue(navBar.waitForExistence(timeout: 3), "Detail view should show")
        }
    }

    // MARK: - Helpers

    private func createReflectionViaManualInput() {
        app.buttons["New Reflection"].tap()

        let senseNames = ["see", "touch", "hear", "smell", "taste"]

        for (index, sense) in senseNames.enumerated() {
            let stepText = app.staticTexts.element(matching: NSPredicate(format: "label CONTAINS[c] %@", sense))
            _ = stepText.waitForExistence(timeout: 5)

            let typeSegment = app.buttons["Type"]
            if typeSegment.waitForExistence(timeout: 2) {
                typeSegment.tap()
            }

            let textField = app.textViews.firstMatch
            if textField.waitForExistence(timeout: 2) {
                textField.tap()
                textField.typeText("Test \(sense) \(index)")
            }

            let nextButton = app.buttons["Next"]
            if nextButton.waitForExistence(timeout: 2) {
                nextButton.tap()
            }
        }

        let saveButton = app.buttons["Save & Close"]
        if saveButton.waitForExistence(timeout: 5) {
            saveButton.tap()
        }

        // Wait to return to home
        _ = app.navigationBars["5-4-3-2-1"].waitForExistence(timeout: 5)
    }
}
