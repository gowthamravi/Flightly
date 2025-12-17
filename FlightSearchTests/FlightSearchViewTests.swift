import XCTest
import SwiftUI
@testable import Flightly

final class FlightSearchViewTests: XCTestCase {

    func testFlightSearchViewInitialState() {
        let view = FlightSearchView()
        let hostingController = UIHostingController(rootView: view)

        XCTAssertNotNil(hostingController.view)
        hostingController.loadViewIfNeeded()

        let departureStation = view.departureStation
        let arrivalStation = view.arrivalStation
        let isRoundTrip = view.isRoundTrip

        XCTAssertEqual(departureStation, "")
        XCTAssertEqual(arrivalStation, "")
        XCTAssertFalse(isRoundTrip)
    }

    func testToggleRoundTrip() {
        var view = FlightSearchView()
        view.isRoundTrip = false

        XCTAssertFalse(view.isRoundTrip)

        view.isRoundTrip.toggle()
        XCTAssertTrue(view.isRoundTrip)
    }

    func testNavigationToPassengerView() {
        let view = FlightSearchView()
        let hostingController = UIHostingController(rootView: view)

        XCTAssertNotNil(hostingController.view)
        hostingController.loadViewIfNeeded()

        let navigationLink = hostingController.view.findSubview(ofType: NavigationLink.self)
        XCTAssertNotNil(navigationLink)
    }
}

private extension UIView {
    func findSubview<T>(ofType type: T.Type) -> T? {
        if let view = self as? T {
            return view
        }
        for subview in subviews {
            if let view = subview.findSubview(ofType: type) {
                return view
            }
        }
        return nil
    }
}