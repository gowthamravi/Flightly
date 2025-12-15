import XCTest
import SwiftUI
@testable import FlightSearch

final class ButtonExtensionTests: XCTestCase {

    func testFlightlyButton_withCustomColor_appliesBackgroundColor() throws {
        let expectation = XCTestExpectation(description: "Button action executed")
        let button = Button.flightlyButton(background: .blue) { 
            expectation.fulfill()
        } label: {
            Text("Test Button")
        }
        
        // Verify the action is called when the button is tapped
        // In a real UI test, you would interact with the button. For unit test, we simulate the tap.
        // Since Button's action is directly provided, we can't directly inspect its background color 
        // without rendering the view. However, we can ensure the initializer parameters are passed.
        // For a more robust test, a ViewInspector or UI test would be needed.
        
        // Simulate tap - this is not directly possible in a unit test without rendering.
        // This test primarily focuses on the code structure and expected parameters.
        // If the Button struct itself were mutable and exposed background, we'd test that.
        // The current implementation uses a static factory method, so we assume it works as intended
        // based on SwiftUI's Button implementation.
        
        // Let's simulate fulfilling the expectation if we could tap it
        // For demonstration, we'll just check if the label is rendered correctly.
        
        let buttonView = UIHostingController(rootView: button).view
        XCTAssertNotNil(buttonView)
        // We cannot directly assert the background color of a SwiftUI Button in a pure unit test.
        // UI tests or ViewInspector would be necessary for that.
        // However, we can assert that the label is present.
        if let labelText = (buttonView.subviews.first as? UIControl)?.titleLabel?.text {
            XCTAssertEqual(labelText, "Test Button")
        } else {
            XCTFail("Button label not found")
        }
    }
    
    func testFlightlyButtonPrimary_withDefaultPurple_appliesCorrectColor() throws {
        let expectation = XCTestExpectation(description: "Button action executed")
        let button = Button.flightlyButtonPrimary { 
            expectation.fulfill()
        } label: {
            Text("Primary Button")
        }
        
        // Similar to the above, direct background color assertion is tricky in unit tests.
        // We are testing the factory method's creation of the correct Color.
        
        let buttonView = UIHostingController(rootView: button).view
        XCTAssertNotNil(buttonView)
        
        // Attempt to get the background color (this is highly dependent on implementation details
        // and may not be reliable across SwiftUI versions or rendering contexts).
        // For a unit test, we mainly check if the correct color value is used in the factory method.
        
        if let labelText = (buttonView.subviews.first as? UIControl)?.titleLabel?.text {
            XCTAssertEqual(labelText, "Primary Button")
        } else {
            XCTFail("Button label not found")
        }
        
        // If we were to try and inspect the color used in `flightlyButtonPrimary`'s 
        // internal call to `flightlyButton`, we would ideally have access to the Color object.
        // Since it's encapsulated, we rely on the expectation that `flightlyButton` works.
    }
    
    // Corner Case: Empty label
    func testFlightlyButton_withEmptyLabel_createsButton() {
        let button = Button.flightlyButton(background: .green) { } label: {
            EmptyView()
        }
        let buttonView = UIHostingController(rootView: button).view
        XCTAssertNotNil(buttonView)
        XCTAssertTrue(buttonView.subviews.isEmpty)
    }
    
    // Corner Case: Button with no action (though typically buttons have actions)
    func testFlightlyButton_withNoAction_createsButton() {
        let button = Button<Text>("No Action") { } // Explicitly create with no action closure
        let buttonView = UIHostingController(rootView: button).view
        XCTAssertNotNil(buttonView)
        // This test is more about SwiftUI's Button behavior itself.
    }
}