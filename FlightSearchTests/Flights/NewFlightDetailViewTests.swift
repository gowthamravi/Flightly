import XCTest
import SwiftUI
@testable import FlightSearch

final class NewFlightDetailViewTests: XCTestCase {

    func testFlightDetailViewRendersCorrectly() {
        let flightName = "Flight 123"
        let departureTime = "10:00 AM"
        let arrivalTime = "12:00 PM"
        let price = "$200"

        let view = NewFlightDetailView(
            flightName: flightName,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            price: price
        )

        let hostingController = UIHostingController(rootView: view)
        XCTAssertNotNil(hostingController.view, "The view should be loaded successfully.")

        hostingController.view.layoutIfNeeded()

        XCTAssertEqual(view.flightName, flightName, "Flight name should match.")
        XCTAssertEqual(view.departureTime, departureTime, "Departure time should match.")
        XCTAssertEqual(view.arrivalTime, arrivalTime, "Arrival time should match.")
        XCTAssertEqual(view.price, price, "Price should match.")
    }
}