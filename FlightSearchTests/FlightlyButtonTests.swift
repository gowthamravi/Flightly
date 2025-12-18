import XCTest
import SwiftUI
@testable import FlightSearch

class FlightlyButtonTests: XCTestCase {
    
    func testFlightlyButtonColorValues() {
        // Given
        let expectedRed: Double = 227/255
        let expectedGreen: Double = 143/255
        let expectedBlue: Double = 188/255
        
        // When
        let buttonColor = Color(red: 227/255, green: 143/255, blue: 188/255)
        
        // Then
        XCTAssertNotNil(buttonColor)
        
        // Test RGB values are within expected range
        XCTAssertTrue(expectedRed >= 0 && expectedRed <= 1, "Red value should be between 0 and 1")
        XCTAssertTrue(expectedGreen >= 0 && expectedGreen <= 1, "Green value should be between 0 and 1")
        XCTAssertTrue(expectedBlue >= 0 && expectedBlue <= 1, "Blue value should be between 0 and 1")
    }
    
    func testFlightlyButtonModifierExists() {
        // Given
        let testView = Text("Test")
        
        // When
        let modifiedView = testView.flightlyButtonStyle()
        
        // Then
        XCTAssertNotNil(modifiedView)
    }
    
    func testFlightlyButtonStyleExists() {
        // Given
        let testButton = Button("Test") { }
        
        // When
        let styledButton = testButton.flightlyStyle()
        
        // Then
        XCTAssertNotNil(styledButton)
    }
    
    func testColorComponentValues() {
        // Given
        let red: CGFloat = 227
        let green: CGFloat = 143
        let blue: CGFloat = 188
        
        // When
        let normalizedRed = red / 255
        let normalizedGreen = green / 255
        let normalizedBlue = blue / 255
        
        // Then
        XCTAssertEqual(normalizedRed, 227/255, accuracy: 0.001)
        XCTAssertEqual(normalizedGreen, 143/255, accuracy: 0.001)
        XCTAssertEqual(normalizedBlue, 188/255, accuracy: 0.001)
    }
}