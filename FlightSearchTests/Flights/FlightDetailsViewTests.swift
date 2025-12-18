//import XCTest
//import SwiftUI
//@testable import FlightSearch
//
//class FlightDetailsViewTests: XCTestCase {
//    
//    var sampleFlight: Flight!
//    
//    override func setUpWithError() throws {
//        super.setUp()
//        sampleFlight = Flight(
//            id: "test123",
//            flightNumber: "AA 1234",
//            departureTime: "10:30 AM",
//            arrivalTime: "2:45 PM",
//            duration: "4h 15m",
//            fare: "$344.00",
//            departureAirport: "JFK",
//            arrivalAirport: "LAX",
//            aircraftType: "Boeing 737-800",
//            baseFareAmount: 299.00,
//            taxesAmount: 45.00,
//            totalFareAmount: 344.00,
//            numberOfStops: 0
//        )
//    }
//    
//    override func tearDownWithError() throws {
//        sampleFlight = nil
//        super.tearDown()
//    }
//    
//    func testFlightDetailsViewInitialization() {
//        // Given
//        let flightDetailsView = FlightDetailsView(flight: sampleFlight)
//        
//        // When
//        let hostingController = UIHostingController(rootView: flightDetailsView)
//        
//        // Then
//        XCTAssertNotNil(hostingController)
//        XCTAssertNotNil(hostingController.rootView)
//    }
//    
//    func testFlightExtensionProperties() {
//        // Test aircraft property
//        XCTAssertEqual(sampleFlight.aircraft, "Boeing 737-800")
//        
//        // Test date property (should not be empty)
//        XCTAssertFalse(sampleFlight.date.isEmpty)
//        
//        // Test baseFare property
//        XCTAssertEqual(sampleFlight.baseFare, "$299.00")
//        
//        // Test taxes property
//        XCTAssertEqual(sampleFlight.taxes, "$45.00")
//        
//        // Test totalFare property
//        XCTAssertEqual(sampleFlight.totalFare, "$344.00")
//        
//        // Test stops property
//        XCTAssertEqual(sampleFlight.stops, "Non-stop")
//    }
//    
//    func testFlightWithStops() {
//        // Given
//        let flightWithStops = Flight(
//            id: "test456",
//            flightNumber: "DL 5678",
//            departureTime: "6:15 AM",
//            arrivalTime: "11:30 AM",
//            duration: "5h 15m",
//            fare: "$289.00",
//            departureAirport: "JFK",
//            arrivalAirport: "LAX",
//            numberOfStops: 1,
//            stopAirports: ["DEN"]
//        )
//        
//        // When & Then
//        XCTAssertEqual(flightWithStops.numberOfStops, 1)
//        XCTAssertEqual(flightWithStops.stopAirports?.first, "DEN")
//    }
//    
//    func testFlightInfoRowComponent() {
//        // Given
//        let title = "Aircraft"
//        let value = "Boeing 737-800"
//        let flightInfoRow = FlightInfoRow(title: title, value: value)
//        
//        // When
//        let hostingController = UIHostingController(rootView: flightInfoRow)
//        
//        // Then
//        XCTAssertNotNil(hostingController)
//    }
//    
//    func testFareDetailRowComponent() {
//        // Given
//        let title = "Base Fare"
//        let amount = "$299.00"
//        let fareDetailRow = FareDetailRow(title: title, amount: amount)
//        
//        // When
//        let hostingController = UIHostingController(rootView: fareDetailRow)
//        
//        // Then
//        XCTAssertNotNil(hostingController)
//    }
//    
//    func testFareDetailRowWithDiscount() {
//        // Given
//        let title = "Discount"
//        let amount = "-$50.00"
//        let fareDetailRow = FareDetailRow(title: title, amount: amount, isDiscount: true)
//        
//        // When
//        let hostingController = UIHostingController(rootView: fareDetailRow)
//        
//        // Then
//        XCTAssertNotNil(hostingController)
//    }
//    
//    func testSampleFlightsData() {
//        // Given
//        let sampleFlights = Flight.sampleFlights
//        
//        // Then
//        XCTAssertEqual(sampleFlights.count, 2)
//        XCTAssertEqual(sampleFlights[0].flightNumber, "AA 1234")
//        XCTAssertEqual(sampleFlights[1].flightNumber, "DL 5678")
//        XCTAssertEqual(sampleFlights[0].numberOfStops, 0)
//        XCTAssertEqual(sampleFlights[1].numberOfStops, 1)
//    }
//    
//    func testFlightModelCodable() throws {
//        // Given
//        let flight = sampleFlight!
//        
//        // When
//        let encodedData = try JSONEncoder().encode(flight)
//        let decodedFlight = try JSONDecoder().decode(Flight.self, from: encodedData)
//        
//        // Then
//        XCTAssertEqual(flight.id, decodedFlight.id)
//        XCTAssertEqual(flight.flightNumber, decodedFlight.flightNumber)
//        XCTAssertEqual(flight.departureTime, decodedFlight.departureTime)
//        XCTAssertEqual(flight.arrivalTime, decodedFlight.arrivalTime)
//        XCTAssertEqual(flight.duration, decodedFlight.duration)
//        XCTAssertEqual(flight.fare, decodedFlight.fare)
//        XCTAssertEqual(flight.departureAirport, decodedFlight.departureAirport)
//        XCTAssertEqual(flight.arrivalAirport, decodedFlight.arrivalAirport)
//    }
//    
//    func testFlightIdentifiable() {
//        // Given
//        let flight1 = sampleFlight!
//        let flight2 = Flight(
//            id: "different123",
//            flightNumber: "UA 9999",
//            departureTime: "8:00 AM",
//            arrivalTime: "12:00 PM",
//            duration: "4h 00m",
//            fare: "$400.00",
//            departureAirport: "LAX",
//            arrivalAirport: "JFK"
//        )
//        
//        // Then
//        XCTAssertNotEqual(flight1.id, flight2.id)
//        XCTAssertEqual(flight1.id, "test123")
//        XCTAssertEqual(flight2.id, "different123")
//    }
//}
