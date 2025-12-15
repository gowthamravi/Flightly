import XCTest
import SwiftUI
@testable import FlightSearch

final class FlightlyButtonTests: XCTestCase {

    func test_backgroundColor_isSetToNewPinkAsPerRequirements() {
        // GIVEN: The design requirement is to use RGB (227, 143, 188).
        let buttonStyle = FlightlyButton()
        let expectedColor = Color(red: 227/255, green: 143/255, blue: 188/255)
        
        // WHEN: The button style is inspected.
        let actualColor = buttonStyle.backgroundColor
        
        // THEN: The background color property must match the new design guidelines.
        XCTAssertEqual(actualColor, expectedColor, "The background color of FlightlyButton should match the new pink color specified in DP-12.")
    }
    
    func test_makeBody_constructsViewWithoutCrashing() {
        // GIVEN: A FlightlyButton style and a standard configuration.
        let buttonStyle = FlightlyButton()
        let label = Text("Test Button")
        let configuration = ButtonStyle.Configuration(label: label, isPressed: false)
        
        // WHEN: The body of the button is created.
        let body = buttonStyle.makeBody(configuration: configuration)
        
        // THEN: The view is created successfully.
        // This acts as a smoke test to ensure the view's structure remains intact and doesn't cause runtime errors,
        // partially verifying the 'Preserve Layout' requirement.
        XCTAssertNotNil(body, "makeBody should successfully return a View instance.")
    }
}
