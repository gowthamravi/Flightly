import XCTest
import SwiftUI
@testable import FlightSearch

final class ButtonExtensionTests: XCTestCase {

    func testFlightlyButtonStyle() {
        let button = Button("Test Button") {}
        let styledButton = button.flightlyButtonStyle()

        let hostingController = UIHostingController(rootView: styledButton)
        XCTAssertNotNil(hostingController.view)

        let buttonColor = hostingController.view.tintColor
        let expectedColor = UIColor(red: 227 / 255, green: 143 / 255, blue: 188 / 255, alpha: 1.0)

        XCTAssertEqual(buttonColor, expectedColor, "Button color does not match expected FlightlyButton color")
    }
}