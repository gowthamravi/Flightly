import XCTest
import SwiftUI
@testable import FlightSearch

final class BrandColorTests: XCTestCase {

    func testFlightlyPinkColorComponentsAreCorrect() {
        // Given
        let expectedRed: CGFloat = 227/255
        let expectedGreen: CGFloat = 143/255
        let expectedBlue: CGFloat = 188/255
        let expectedAlpha: CGFloat = 1.0

        // When
        let sut = BrandColor.flightlyPink
        
        // To test a SwiftUI Color, we convert it to a UIColor to inspect its components.
        let uiColor = UIColor(sut)

        var actualRed: CGFloat = 0
        var actualGreen: CGFloat = 0
        var actualBlue: CGFloat = 0
        var actualAlpha: CGFloat = 0

        uiColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)

        // Then
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component should match the design spec (227/255)")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component should match the design spec (143/255)")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component should match the design spec (188/255)")
        XCTAssertEqual(actualAlpha, expectedAlpha, accuracy: 0.001, "Alpha component should be fully opaque")
    }
}
