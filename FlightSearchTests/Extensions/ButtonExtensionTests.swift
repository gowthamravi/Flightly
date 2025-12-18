import XCTest
import SwiftUI
@testable import FlightSearch

final class ButtonExtensionTests: XCTestCase {
    
    func testFlightlyButtonCreation() {
        let button = FlightlyButton(title: "Test Button") {
            // Test action
        }
        
        XCTAssertNotNil(button)
    }
    
    func testFlightlyPrimaryColorValues() {
        let expectedRed: Double = 227/255
        let expectedGreen: Double = 143/255
        let expectedBlue: Double = 188/255
        
        let color = Color.flightlyPrimary
        XCTAssertNotNil(color)
        
        // Test that the color components match expected values
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(Double(red), expectedRed, accuracy: 0.01)
        XCTAssertEqual(Double(green), expectedGreen, accuracy: 0.01)
        XCTAssertEqual(Double(blue), expectedBlue, accuracy: 0.01)
        XCTAssertEqual(Double(alpha), 1.0, accuracy: 0.01)
    }
    
    func testFlightlyButtonStyleApplication() {
        let testButton = Button("Test") { }
        let styledButton = testButton.flightlyStyle()
        
        XCTAssertNotNil(styledButton)
    }
    
    func testFlightlyButtonStyleConfiguration() {
        let buttonStyle = FlightlyButtonStyle()
        let configuration = ButtonStyleConfiguration(
            label: ButtonStyleConfiguration.Label(Text("Test")),
            isPressed: false
        )
        
        let styledView = buttonStyle.makeBody(configuration: configuration)
        XCTAssertNotNil(styledView)
    }
    
    func testFlightlyButtonStylePressedState() {
        let buttonStyle = FlightlyButtonStyle()
        let pressedConfiguration = ButtonStyleConfiguration(
            label: ButtonStyleConfiguration.Label(Text("Test")),
            isPressed: true
        )
        
        let pressedView = buttonStyle.makeBody(configuration: pressedConfiguration)
        XCTAssertNotNil(pressedView)
    }
}