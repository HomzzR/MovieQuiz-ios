import XCTest

final class MovieQuizUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(firstPoster.exists)
        
        app.buttons["Yes"].tap()
        sleep(3)
        
        XCTAssertEqual(indexLabel.label, "2/10")
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertTrue(secondPoster.exists)
        
        XCTAssertNotEqual(firstPoster, secondPoster)
    }
    
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(firstPoster.exists)
        
        app.buttons["No"].tap()
        sleep(3)
        
        XCTAssertEqual(indexLabel.label, "2/10")
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertTrue(secondPoster.exists)
        
        XCTAssertNotEqual(firstPoster, secondPoster)
    }

    func testAlertShow() {
        sleep(4)
        for _ in 1...10 {
            app.buttons["No"].tap()
            sleep(2)
        }
        
        XCTAssertEqual(app.staticTexts["Index"].label, "10/10")
        let alert = app.alerts["Alert"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Этот раунд окончен!")
    }
    
}
