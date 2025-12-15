import XCTest
import SwiftUI
@testable import FlightSearch // Import the main module to access extensions

final class ColorExtensionTests: XCTestCase {

    /// Tests that the `flightlyPrimary` color has the correct RGB components.
    func testFlightlyPrimaryColorComponents() {
        let expectedRed: CGFloat = 227 / 255.0
        let expectedGreen: CGFloat = 143 / 255.0
        let expectedBlue: CGFloat = 188 / 255.0

        // Convert SwiftUI Color to UIColor to extract individual components for testing.
        // SwiftUI's Color doesn't directly expose RGB components.
        let uiColor = UIColor(Color.flightlyPrimary)

        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0

        // Extract the color components.
        uiColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)

        // Assert that the actual components match the expected components within a small accuracy tolerance.
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component of flightlyPrimary should match")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component of flightlyPrimary should match")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component of flightlyPrimary should match")
        XCTAssertEqual(actualAlpha, 1.0, "Alpha component of flightlyPrimary should be 1.0 (opaque)")
    }
}
