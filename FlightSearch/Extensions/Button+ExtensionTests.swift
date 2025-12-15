import XCTest
import SwiftUI
@testable import FlightSearch

final class ButtonExtensionTests: XCTestCase {

    func testFlightlyButtonStyle() {
        // Given
        let button = Button("Test Button") {}
        let styledButton = button.flightlyButtonStyle()

        // When
        let hostingController = UIHostingController(rootView: styledButton)
        let view = hostingController.view

        // Then
        XCTAssertNotNil(view, "The styled button should have a valid view.")

        // Additional checks can be added here to verify the background color and other properties
    }
}