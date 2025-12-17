import XCTest
import SwiftUI
@testable import Flightly

final class FlightSearchViewTests: XCTestCase {

    func testInitialState() {
        let view = FlightSearchView()
        let hostingController = UIHostingController(rootView: view)

        XCTAssertNotNil(hostingController.view)
        XCTAssertFalse(view.isRoundTrip, "Initial state of isRoundTrip should be false")
    }

    func testToggleRoundTrip() {
        var view = FlightSearchView()
        view.isRoundTrip = true

        XCTAssertTrue(view.isRoundTrip, "isRoundTrip should be true after toggling")
    }

    func testSearchFlights() {
        let view = FlightSearchView()
        let expectation = XCTestExpectation(description: "Search flights action triggered")

        view.searchFlights()
        expectation.fulfill()

        wait(for: [expectation], timeout: 1.0)
    }
}