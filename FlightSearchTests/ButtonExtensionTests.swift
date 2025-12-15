import XCTest
import SwiftUI
@testable import FlightSearch

final class ButtonExtensionTests: XCTestCase {

    func testFlightlyButtonStyle() {
        // Create a button with the flightlyButtonStyle applied
        let button = Button("Test Button") {}
            .flightlyButtonStyle()

        // Extract the background color from the button
        let backgroundColor = button.backgroundColor

        // Assert the background color matches the expected color
        XCTAssertEqual(backgroundColor, Color(red: 227 / 255, green: 143 / 255, blue: 188 / 255))
    }
}

// Helper extension to extract background color for testing
extension View {
    var backgroundColor: Color? {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let color = child.value as? Color {
                return color
            }
        }
        return nil
    }
}