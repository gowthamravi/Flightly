import XCTest
import SwiftUI
@testable import FlightSearch

class ButtonExtensionTests: XCTestCase {

    func testFlightlyButtonBackgroundColor() {
        // Given
        let expectedColor = Color(red: 227/255, green: 143/255, blue: 188/255)
        let buttonStyleColor = FlightlyButton.backgroundColor

        // When
        // Convert to UIColor to compare components, as SwiftUI.Color is opaque.
        let expectedUIColor = UIColor(expectedColor)
        let actualUIColor = UIColor(buttonStyleColor)

        var expectedRed: CGFloat = 0, expectedGreen: CGFloat = 0, expectedBlue: CGFloat = 0, expectedAlpha: CGFloat = 0
        expectedUIColor.getRed(&expectedRed, green: &expectedGreen, blue: &expectedBlue, alpha: &expectedAlpha)

        var actualRed: CGFloat = 0, actualGreen: CGFloat = 0, actualBlue: CGFloat = 0, actualAlpha: CGFloat = 0
        actualUIColor.getRed(&actualRed, green: &actualGreen, blue: &actualBlue, alpha: &actualAlpha)

        // Then
        XCTAssertEqual(actualRed, expectedRed, accuracy: 0.001, "Red component does not match")
        XCTAssertEqual(actualGreen, expectedGreen, accuracy: 0.001, "Green component does not match")
        XCTAssertEqual(actualBlue, expectedBlue, accuracy: 0.001, "Blue component does not match")
    }
}
