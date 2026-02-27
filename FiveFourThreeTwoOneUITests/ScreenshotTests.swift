import XCTest

final class ScreenshotTests: XCTestCase {

    let app = XCUIApplication()
    let screenshotsDir = "/Users/dancao/Documents/54321/screenshots"

    override func setUpWithError() throws {
        continueAfterFailure = true
        app.launch()
    }

    func testCaptureAppStoreScreenshots() throws {
        // Screenshot 1: Home Screen (empty state)
        sleep(2)
        let homeScreenshot = XCUIScreen.main.screenshot()
        saveScreenshot(homeScreenshot, name: "01_home_screen")

        // Tap New Reflection button
        let newReflectionButton = app.buttons["New Reflection"]
        if newReflectionButton.waitForExistence(timeout: 5) {
            newReflectionButton.tap()
        }

        // Screenshot 2: Breathing Countdown
        sleep(1)
        let breathingScreenshot = XCUIScreen.main.screenshot()
        saveScreenshot(breathingScreenshot, name: "02_breathing_countdown")

        // Wait for breathing countdown to finish (3 seconds + transition)
        sleep(5)

        // Screenshot 3: First sense step (See - 5 things)
        sleep(1)
        let seeStepScreenshot = XCUIScreen.main.screenshot()
        saveScreenshot(seeStepScreenshot, name: "03_see_step")

        // Try to switch to manual/type mode if there's a toggle
        let typeButton = app.buttons["Type"]
        if typeButton.waitForExistence(timeout: 3) {
            typeButton.tap()
            sleep(1)

            // Screenshot 4: Manual text entry mode
            let manualScreenshot = XCUIScreen.main.screenshot()
            saveScreenshot(manualScreenshot, name: "04_manual_input")
        }
    }

    func testCaptureSettingsScreenshot() throws {
        // Navigate to settings
        sleep(2)
        let settingsButton = app.buttons["Settings"]
        if settingsButton.waitForExistence(timeout: 5) {
            settingsButton.tap()
            sleep(1)

            // Screenshot 5: Settings / Custom Prompts
            let settingsScreenshot = XCUIScreen.main.screenshot()
            saveScreenshot(settingsScreenshot, name: "05_settings")
        }
    }

    // MARK: - Helper

    private func saveScreenshot(_ screenshot: XCUIScreenshot, name: String) {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)

        // Also save to disk
        let data = screenshot.pngRepresentation
        let fileURL = URL(fileURLWithPath: screenshotsDir).appendingPathComponent("\(name).png")
        try? data.write(to: fileURL)
    }
}
