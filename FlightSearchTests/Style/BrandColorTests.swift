import XCTest
import SwiftUI
@testable import FlightSearch

final class BrandColorTests: XCTestCase {

    func testBrandPinkColor_HasCorrectRGBValues() {
        // Given
        let brandColor = Color.brandPink
        let expectedRed: CGFloat = 227 / 255.0
        let expectedGreen: CGFloat = 143 / 255.0
        let expectedBlue: CGFloat = 188 / 255.0
        
        // When
        let uiColor = UIColor(brandColor)
        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0
        
        let conversionSuccess = uiColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)
        
        // Then
        XCTAssertTrue(conversionSuccess, "Failed to convert SwiftUI Color to UIColor components.")
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component does not match the expected value.")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component does not match the expected value.")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component does not match the expected value.")
        XCTAssertEqual(actualAlpha, 1.0, accuracy: 0.001, "Alpha component should be fully opaque.")
    }
}
