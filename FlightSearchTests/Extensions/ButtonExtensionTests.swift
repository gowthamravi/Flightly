import XCTest
@testable import FlightSearch

class ButtonExtensionTests: XCTestCase {

    func testApplyFlightlyStyle() {
        // Arrange
        let button = UIButton()
        
        // Act
        button.applyFlightlyStyle()
        
        // Assert
        let expectedBackgroundColor = UIColor(red: 227/255, green: 143/255, blue: 188/255, alpha: 1.0)
        XCTAssertEqual(button.backgroundColor, expectedBackgroundColor, "Button background color should be updated to the new brand color.")
        XCTAssertEqual(button.titleColor(for: .normal), UIColor.white, "Button text color should remain white.")
    }
}