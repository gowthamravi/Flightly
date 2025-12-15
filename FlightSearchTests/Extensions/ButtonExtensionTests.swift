import XCTest
@testable import FlightSearch

class ButtonExtensionTests: XCTestCase {

    func testApplyFlightlyStyle() {
        // Given
        let button = UIButton()
        
        // When
        button.applyFlightlyStyle()
        
        // Then
        let expectedBackgroundColor = UIColor(red: 227/255, green: 143/255, blue: 188/255, alpha: 1.0)
        XCTAssertEqual(button.backgroundColor, expectedBackgroundColor, "Button background color should match the new brand color.")
        XCTAssertEqual(button.titleColor(for: .normal), .white, "Button text color should remain white.")
    }
}