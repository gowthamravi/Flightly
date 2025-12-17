import XCTest
import SwiftUI
@testable import FlightSearch

final class FlightSearchViewTests: XCTestCase {

    func testFlightSearchViewRendersCorrectly() {
        let flightSearchView = FlightSearchView()
        let hostingController = UIHostingController(rootView: flightSearchView)

        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(hostingController.title, nil)
    }

    func testFlightSearchViewInitialState() {
        let flightSearchView = FlightSearchView()

        XCTAssertEqual(flightSearchView.departureStation, "")
        XCTAssertEqual(flightSearchView.arrivalStation, "")
        XCTAssertEqual(flightSearchView.passengerCount, 1)
    }

    func testFlightSearchButtonAction() {
        let flightSearchView = FlightSearchView()
        let expectation = XCTestExpectation(description: "Search button tapped")

        // Simulate button tap
        flightSearchView.body

        // Add your assertions here for button action
        expectation.fulfill()
        wait(for: [expectation], timeout: 1.0)
    }
}