import XCTest
import SwiftUI
@testable import FlightSearch

final class FlightlyButtonTests: XCTestCase {

    /// Tests that the underlying color constant for the FlightlyButton has the correct RGB values.
    ///
    /// Note: Directly testing the rendered background color of a SwiftUI View in a pure XCTest
    /// is complex and often requires snapshot testing. By testing the source color constant (`BrandColor.flightlyPink`),
    /// we verify the core requirement of the change (DP-12) in a reliable and maintainable way.
    func testFlightlyButtonBackgroundColorIsCorrect() throws {
        // 1. GIVEN: The brand color used for the FlightlyButton background.
        let buttonColor = BrandColor.flightlyPink
        let expectedRed: CGFloat = 227/255
        let expectedGreen: CGFloat = 143/255
        let expectedBlue: CGFloat = 188/255

        // 2. WHEN: We inspect the color's components.
        // We convert to UIColor to reliably access the underlying RGBA components.
        let uiColor = UIColor(buttonColor)
        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0
        
        uiColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)

        // 3. THEN: The RGB components should match the new design guidelines.
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component does not match the expected value.")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component does not match the expected value.")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component does not match the expected value.")
        XCTAssertEqual(actualAlpha, 1.0, "Alpha component should be 1.0 for an opaque color.")
    }
}
