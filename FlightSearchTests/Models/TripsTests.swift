import XCTest
@testable import FlightSearch

class TripsTests: XCTestCase {

    func testTripComputedProperties() {
        // Given
        let trip = Trip.mock
        
        // When
        let firstFlight = trip.firstFlight
        let totalFare = trip.totalFare
        
        // Then
        XCTAssertNotNil(firstFlight, "First flight should not be nil for mock trip")
        XCTAssertEqual(firstFlight?.flightNumber, "FR123")
        
        XCTAssertNotNil(totalFare, "Total fare should not be nil for mock trip")
        XCTAssertEqual(totalFare, 120.99)
    }
    
    func testFlightComputedProperties() {
        // Given
        guard let flight = Trip.mock.firstFlight else {
            XCTFail("Failed to get mock flight")
            return
        }
        
        // When
        let departureTime = flight.departureTime
        let arrivalTime = flight.arrivalTime
        let airline = flight.airline
        let formattedDuration = flight.formattedDuration
        
        // Then
        XCTAssertEqual(departureTime, "2024-09-20T06:30:00.000")
        XCTAssertEqual(arrivalTime, "2024-09-20T09:50:00.000")
        
        XCTAssertNotNil(airline)
        XCTAssertEqual(airline?.code, "FR")
        XCTAssertEqual(airline?.name, "Ryanair")
        
        XCTAssertEqual(formattedDuration, "2h 20m")
    }
    
    func testPassengerSummaryFormattingHelper() {
        // This logic lives inside FlightsListView. To test it cleanly,
        // it should be extracted into a view model or a dedicated formatter.
        // For this test, we replicate the logic to verify its behavior.
        
        // Given
        let passengers1 = Passengers(adults: 1, teens: 0, children: 0)
        let passengers2 = Passengers(adults: 2, teens: 1, children: 0)
        let passengers3 = Passengers(adults: 1, teens: 0, children: 2)
        let passengers4 = Passengers(adults: 1, teens: 1, children: 1)

        // When
        let summary1 = formatPassengers(passengers1)
        let summary2 = formatPassengers(passengers2)
        let summary3 = formatPassengers(passengers3)
        let summary4 = formatPassengers(passengers4)

        // Then
        XCTAssertEqual(summary1, "1 Adult")
        XCTAssertEqual(summary2, "2 Adults, 1 Teen")
        XCTAssertEqual(summary3, "1 Adult, 2 Children")
        XCTAssertEqual(summary4, "1 Adult, 1 Teen, 1 Child")
    }
    
    // Helper function mirroring the logic in FlightsListView
    private func formatPassengers(_ passengers: Passengers) -> String {
        var parts: [String] = []
        if passengers.adults > 0 {
            parts.append("\(passengers.adults) Adult" + (passengers.adults > 1 ? "s" : ""))
        }
        if passengers.teens > 0 {
            parts.append("\(passengers.teens) Teen" + (passengers.teens > 1 ? "s" : ""))
        }
        if passengers.children > 0 {
            parts.append("\(passengers.children) " + (passengers.children > 1 ? "Children" : "Child"))
        }
        return parts.joined(separator: ", ")
    }
}
