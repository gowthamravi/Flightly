//import XCTest
//@testable import FlightSearch
//
//class FlightTests: XCTestCase {
//    
//    func testFlightInitialization() {
//        // Given
//        let id = "FL123"
//        let flightNumber = "AA 1234"
//        let departureTime = "10:30 AM"
//        let arrivalTime = "2:45 PM"
//        let duration = "4h 15m"
//        let fare = "$344.00"
//        let departureAirport = "JFK"
//        let arrivalAirport = "LAX"
//        
//        // When
//        let flight = Flight(
//            id: id,
//            flightNumber: flightNumber,
//            departureTime: departureTime,
//            arrivalTime: arrivalTime,
//            duration: duration,
//            fare: fare,
//            departureAirport: departureAirport,
//            arrivalAirport: arrivalAirport
//        )
//        
//        // Then
//        XCTAssertEqual(flight.id, id)
//        XCTAssertEqual(flight.flightNumber, flightNumber)
//        XCTAssertEqual(flight.departureTime, departureTime)
//        XCTAssertEqual(flight.arrivalTime, arrivalTime)
//        XCTAssertEqual(flight.duration, duration)
//        XCTAssertEqual(flight.fare, fare)
//        XCTAssertEqual(flight.departureAirport, departureAirport)
//        XCTAssertEqual(flight.arrivalAirport, arrivalAirport)
//    }
//    
//    func testFlightWithOptionalProperties() {
//        // Given
//        let flight = Flight(
//            id: "FL456",
//            flightNumber: "DL 5678",
//            departureTime: "6:15 AM",
//            arrivalTime: "11:30 AM",
//            duration: "5h 15m",
//            fare: "$289.00",
//            departureAirport: "JFK",
//            arrivalAirport: "LAX",
//            aircraftType: "Airbus A320",
//            baseFareAmount: 249.00,
//            taxesAmount: 40.00,
//            totalFareAmount: 289.00,
//            numberOfStops: 1,
//            stopAirports: ["DEN"]
//        )
//        
//        // Then
//        XCTAssertEqual(flight.aircraftType, "Airbus A320")
//        XCTAssertEqual(flight.baseFareAmount, 249.00)
//        XCTAssertEqual(flight.taxesAmount, 40.00)
//        XCTAssertEqual(flight.totalFareAmount, 289.00)
//        XCTAssertEqual(flight.numberOfStops, 1)
//        XCTAssertEqual(flight.stopAirports?.count, 1)
//        XCTAssertEqual(flight.stopAirports?.first, "DEN")
//    }
//    
//    func testFlightCodableEncoding() throws {
//        // Given
//        let flight = Flight(
//            id: "FL789",
//            flightNumber: "UA 9876",
//            departureTime: "8:00 AM",
//            arrivalTime: "12:00 PM",
//            duration: "4h 00m",
//            fare: "$400.00",
//            departureAirport: "LAX",
//            arrivalAirport: "JFK"
//        )
//        
//        // When
//        let encodedData = try JSONEncoder().encode(flight)
//        
//        // Then
//        XCTAssertNotNil(encodedData)
//        XCTAssertGreaterThan(encodedData.count, 0)
//    }
//    
//    func testFlightCodableDecoding() throws {
//        // Given
//        let jsonString = """
//        {
//            "id": "FL999",
//            "flightNumber": "SW 1111",
//            "departureTime": "9:00 AM",
//            "arrivalTime": "1:00 PM",
//            "duration": "4h 00m",
//            "fare": "$199.00",
//            "departureAirport": "LAX",
//            "arrivalAirport": "JFK"
//        }
//        """
//        
//        let jsonData = jsonString.data(using: .utf8)!
//        
//        // When
//        let decodedFlight = try JSONDecoder().decode(Flight.self, from: jsonData)
//        
//        // Then
//        XCTAssertEqual(decodedFlight.id, "FL999")
//        XCTAssertEqual(decodedFlight.flightNumber, "SW 1111")
//        XCTAssertEqual(decodedFlight.departureTime, "9:00 AM")
//        XCTAssertEqual(decodedFlight.arrivalTime, "1:00 PM")
//        XCTAssertEqual(decodedFlight.duration, "4h 00m")
//        XCTAssertEqual(decodedFlight.fare, "$199.00")
//        XCTAssertEqual(decodedFlight.departureAirport, "LAX")
//        XCTAssertEqual(decodedFlight.arrivalAirport, "JFK")
//    }
//    
//    func testFlightIdentifiableProtocol() {
//        // Given
//        let flight1 = Flight(
//            id: "FL001",
//            flightNumber: "AA 1111",
//            departureTime: "10:00 AM",
//            arrivalTime: "2:00 PM",
//            duration: "4h 00m",
//            fare: "$300.00",
//            departureAirport: "JFK",
//            arrivalAirport: "LAX"
//        )
//        
//        let flight2 = Flight(
//            id: "FL002",
//            flightNumber: "AA 2222",
//            departureTime: "11:00 AM",
//            arrivalTime: "3:00 PM",
//            duration: "4h 00m",
//            fare: "$350.00",
//            departureAirport: "JFK",
//            arrivalAirport: "LAX"
//        )
//        
//        // Then
//        XCTAssertNotEqual(flight1.id, flight2.id)
//        XCTAssertEqual(flight1.id, "FL001")
//        XCTAssertEqual(flight2.id, "FL002")
//    }
//    
//    func testSampleFlightsNotEmpty() {
//        // Given & When
//        let sampleFlights = Flight.sampleFlights
//        
//        // Then
//        XCTAssertFalse(sampleFlights.isEmpty)
//        XCTAssertGreaterThan(sampleFlights.count, 0)
//    }
//    
//    func testSampleFlightsContent() {
//        // Given
//        let sampleFlights = Flight.sampleFlights
//        
//        // Then
//        XCTAssertEqual(sampleFlights.count, 2)
//        
//        let firstFlight = sampleFlights[0]
//        XCTAssertEqual(firstFlight.id, "1")
//        XCTAssertEqual(firstFlight.flightNumber, "AA 1234")
//        XCTAssertEqual(firstFlight.numberOfStops, 0)
//        
//        let secondFlight = sampleFlights[1]
//        XCTAssertEqual(secondFlight.id, "2")
//        XCTAssertEqual(secondFlight.flightNumber, "DL 5678")
//        XCTAssertEqual(secondFlight.numberOfStops, 1)
//        XCTAssertEqual(secondFlight.stopAirports?.first, "DEN")
//    }
//}
