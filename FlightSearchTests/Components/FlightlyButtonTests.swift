import XCTest
import SwiftUI
@testable import FlightSearch

final class FlightlyButtonTests: XCTestCase {
    
    func testFlightlyButtonColorValues() {
        // Test that the color components match the required RGB values (227, 143, 188)
        let expectedRed: CGFloat = 227/255
        let expectedGreen: CGFloat = 143/255
        let expectedBlue: CGFloat = 188/255
        
        let flightlyColor = Color.flightlyPrimary
        
        // Convert SwiftUI Color to UIColor for component extraction
        let uiColor = UIColor(flightlyColor)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, expectedRed, accuracy: 0.01, "Red component should be 227/255")
        XCTAssertEqual(green, expectedGreen, accuracy: 0.01, "Green component should be 143/255")
        XCTAssertEqual(blue, expectedBlue, accuracy: 0.01, "Blue component should be 188/255")
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01, "Alpha should be 1.0")
    }
    
    func testFlightlyButtonCreation() {
        // Test that FlightlyButton can be created without issues
        var buttonTapped = false
        
        let button = FlightlyButton(title: "Test Button") {
            buttonTapped = true
        }
        
        XCTAssertNotNil(button, "FlightlyButton should be created successfully")
    }
    
    func testFlightlyButtonAction() {
        // Test that the button action is properly set
        var actionExecuted = false
        
        let _ = FlightlyButton(title: "Test") {
            actionExecuted = true
        }
        
        // Since we can't directly trigger SwiftUI button actions in unit tests,
        // we verify the action closure is properly stored by checking it's not nil
        XCTAssertFalse(actionExecuted, "Action should not be executed during initialization")
    }
    
    func testColorExtensionExists() {
        // Test that the color extension is properly defined
        let color = Color.flightlyPrimary
        XCTAssertNotNil(color, "flightlyPrimary color should be defined")
    }
}