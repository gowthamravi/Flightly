import XCTest
import SwiftUI
@testable import FlightSearch

class ButtonExtensionTests: XCTestCase {

    func testFlightlyPinkColor_hasCorrectRGBValues() {
        // Given
        let expectedRed: CGFloat = 227/255
        let expectedGreen: CGFloat = 143/255
        let expectedBlue: CGFloat = 188/255
        let colorUnderTest = Color.flightlyPink

        // When
        // We convert to UIColor to inspect the underlying component values,
        // as SwiftUI.Color does not expose them directly.
        let uiColor = UIColor(colorUnderTest)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        let conversionSuccess = uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Then
        XCTAssertTrue(conversionSuccess, "Color to UIColor conversion should succeed.")
        XCTAssertEqual(red, expectedRed, accuracy: 0.001, "Red component should match the design spec (227/255).")
        XCTAssertEqual(green, expectedGreen, accuracy: 0.001, "Green component should match the design spec (143/255).")
        XCTAssertEqual(blue, expectedBlue, accuracy: 0.001, "Blue component should match the design spec (188/255).")
        XCTAssertEqual(alpha, 1.0, accuracy: 0.001, "Alpha component should be 1.0 (fully opaque).")
    }
}
