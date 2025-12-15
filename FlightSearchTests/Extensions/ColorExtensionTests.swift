import XCTest
import SwiftUI
@testable import FlightSearch

final class ColorExtensionTests: XCTestCase {

    func testBrandPrimaryColorComponents() {
        // Given
        let brandColor = Color.brandPrimary
        let expectedRed: CGFloat = 227 / 255
        let expectedGreen: CGFloat = 143 / 255
        let expectedBlue: CGFloat = 188 / 255

        // When
        // We convert SwiftUI Color to UIColor to inspect its components for the test.
        let uiColor = UIColor(brandColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        let success = uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)

        // Then
        XCTAssertTrue(success, "Should be able to extract color components.")
        XCTAssertEqual(red, expectedRed, accuracy: 0.001, "The red component should match the new brand color.")
        XCTAssertEqual(green, expectedGreen, accuracy: 0.001, "The green component should match the new brand color.")
        XCTAssertEqual(blue, expectedBlue, accuracy: 0.001, "The blue component should match the new brand color.")
    }
}
