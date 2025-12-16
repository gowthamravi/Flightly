import XCTest
import SwiftUI
@testable import FlightSearch

final class BrandColorTests: XCTestCase {

    func testPrimaryButtonColorIsUpdatedToNewPink() {
        // GIVEN: The required RGB values from ticket DP-12.
        let expectedRed: CGFloat = 227.0 / 255.0
        let expectedGreen: CGFloat = 143.0 / 255.0
        let expectedBlue: CGFloat = 188.0 / 255.0
        let primaryButtonColor = BrandColor.primaryButton

        // WHEN: The SwiftUI Color is converted to its UIColor representation to inspect its components.
        let uiColor = UIColor(primaryButtonColor)
        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0
        
        let conversionSuccess = uiColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)

        // THEN: The color components must match the new design guidelines precisely.
        XCTAssertTrue(conversionSuccess, "Should be able to convert SwiftUI Color to UIColor components.")
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component does not match the new design guidelines (227/255).")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component does not match the new design guidelines (143/255).")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component does not match the new design guidelines (188/255).")
        XCTAssertEqual(actualAlpha, 1.0, accuracy: 0.001, "Color should be fully opaque.")
    }
}
