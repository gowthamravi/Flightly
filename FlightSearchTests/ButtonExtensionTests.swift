import XCTest
import SwiftUI
@testable import FlightSearch

final class ButtonExtensionTests: XCTestCase {

    func testFlightlyButtonBackgroundColor() {
        let button = FlightlyButton(title: "Test Button")
        let hostingController = UIHostingController(rootView: button)

        XCTAssertNotNil(hostingController.view)

        let buttonView = hostingController.view.subviews.first(where: { $0 is UIButton })
        XCTAssertNotNil(buttonView)

        if let buttonView = buttonView as? UIButton {
            let backgroundColor = buttonView.backgroundColor
            let expectedColor = UIColor(red: 227/255, green: 143/255, blue: 188/255, alpha: 1)
            XCTAssertEqual(backgroundColor, expectedColor, "Button background color does not match the expected pink color.")
        }
    }

    func testFlightlyButtonTextColor() {
        let button = FlightlyButton(title: "Test Button")
        let hostingController = UIHostingController(rootView: button)

        XCTAssertNotNil(hostingController.view)

        let buttonView = hostingController.view.subviews.first(where: { $0 is UIButton })
        XCTAssertNotNil(buttonView)

        if let buttonView = buttonView as? UIButton {
            let textColor = buttonView.titleColor(for: .normal)
            XCTAssertEqual(textColor, UIColor.white, "Button text color is not white.")
        }
    }
}