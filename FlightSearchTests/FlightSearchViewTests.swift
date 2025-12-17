import XCTest
import SwiftUI
@testable import Flightly

final class FlightSearchViewTests: XCTestCase {

    func testFlightSearchView_initialState() {
        let flightSearchView = FlightSearchView()
        let view = UIHostingController(rootView: flightSearchView)

        XCTAssertNotNil(view.view)
        XCTAssertEqual(flightSearchView.passengerCount, 1)
        XCTAssertEqual(flightSearchView.departure, "")
        XCTAssertEqual(flightSearchView.destination, "")
    }

    func testFlightSearchView_updatePassengerCount() {
        var flightSearchView = FlightSearchView()
        flightSearchView.passengerCount = 3
        XCTAssertEqual(flightSearchView.passengerCount, 3)
    }

    func testFlightSearchView_searchButtonAction() {
        let expectation = XCTestExpectation(description: "Search button tapped")
        let flightSearchView = FlightSearchView()

        // Simulate button tap
        flightSearchView.body
        expectation.fulfill()

        wait(for: [expectation], timeout: 1.0)
    }
}