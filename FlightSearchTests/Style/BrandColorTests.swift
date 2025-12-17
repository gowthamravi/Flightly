import XCTest
import SwiftUI
@testable import FlightSearch

final class BrandColorTests: XCTestCase {

    func testFlightlyPinkColor_HasCorrectRGBValues_AsPer_DP12() {
        // Given
        let expectedRed: CGFloat = 227/255
        let expectedGreen: CGFloat = 143/255
        let expectedBlue: CGFloat = 188/255
        let colorUnderTest = BrandColor.flightlyPink

        // When
        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0

        // Convert SwiftUI Color to UIColor to inspect its components
        let uiColor = UIColor(colorUnderTest)
        uiColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)

        // Then
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component does not match the design spec.")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component does not match the design spec.")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component does not match the design spec.")
        XCTAssertEqual(actualAlpha, 1.0, "Alpha component should be 1.0 for an opaque color.")
    }
}
