import Foundation

// Represents the API response for a flight search
struct Trips: Codable {
    let trips: [Trip]
}

// Represents a journey option, which may include one or more flights
struct Trip: Codable, Identifiable {
    let id = UUID()
    let origin: String
    let destination: String
    let dates: [TripDate]

    // Helper to get the first flight for display, as per the simple UI design
    var firstFlight: Flight? {
        dates.first?.flights.first
    }

    // Helper to get the total fare for the first flight option
    var totalFare: Double? {
        firstFlight?.regularFare?.fares.first?.amount
    }

    enum CodingKeys: String, CodingKey {
        case origin, destination, dates
    }
}

// Represents flights available on a specific date
struct TripDate: Codable {
    let dateOut: String
    let flights: [Flight]
}

// Represents a single flight segment
struct Flight: Codable {
    let flightNumber: String
    let duration: String
    let time: [String] // Array of ISO 8601 date strings [departure, arrival]
    let regularFare: RegularFare?
    let infantsLeft: Int
    let segments: [Segment]

    var departureTime: String? {
        time.first
    }

    var arrivalTime: String? {
        time.last
    }
    
    var airline: (code: String, name: String)? {
        guard let operatorCode = segments.first?.flightNumber.prefix(2) else { return nil }
        let code = String(operatorCode)
        // In a real app, this would come from a configuration or a separate API
        let airlineName: String
        switch code {
        case "FR": airlineName = "Ryanair"
        case "EI": airlineName = "Aer Lingus"
        case "LH": airlineName = "Lufthansa"
        default: airlineName = code
        }
        return (code: code, name: airlineName)
    }
    
    var formattedDuration: String {
        duration.replacingOccurrences(of: ":", with: "h ") + "m"
    }
}

// Contains details about the fare
struct RegularFare: Codable {
    let fareKey: String
    let fareClass: String
    let fares: [Fare]
}

// Represents the cost for a specific passenger type
struct Fare: Codable {
    let type: String // e.g., "ADT" for adult
    let amount: Double
    let count: Int
}

// Represents a leg of a flight, useful for connecting flights
struct Segment: Codable {
    let origin: String
    let destination: String
    let flightNumber: String
    let duration: String
}

// MARK: - Mock Data for Previews and Tests
extension Trip {
    static var mock: Trip {
        Trip(
            origin: "DUB",
            destination: "BER",
            dates: [
                TripDate(
                    dateOut: "2024-09-20T00:00:00.000",
                    flights: [
                        Flight(
                            flightNumber: "FR123",
                            duration: "02:20",
                            time: ["2024-09-20T06:30:00.000", "2024-09-20T09:50:00.000"],
                            regularFare: RegularFare(
                                fareKey: "some_fare_key",
                                fareClass: "E",
                                fares: [
                                    Fare(type: "ADT", amount: 120.99, count: 1)
                                ]
                            ),
                            infantsLeft: 5,
                            segments: [
                                Segment(origin: "DUB", destination: "BER", flightNumber: "FR123", duration: "02:20")
                            ]
                        )
                    ]
                )
            ]
        )
    }
    
    static var mockTrips: [Trip] {
        [
            Trip.mock,
            Trip(
                origin: "DUB",
                destination: "BER",
                dates: [
                    TripDate(
                        dateOut: "2024-09-20T00:00:00.000",
                        flights: [
                            Flight(
                                flightNumber: "EI332",
                                duration: "02:15",
                                time: ["2024-09-20T09:00:00.000", "2024-09-20T12:15:00.000"],
                                regularFare: RegularFare(
                                    fareKey: "another_fare_key",
                                    fareClass: "Y",
                                    fares: [
                                        Fare(type: "ADT", amount: 155.50, count: 1)
                                    ]
                                ),
                                infantsLeft: 3,
                                segments: [
                                    Segment(origin: "DUB", destination: "BER", flightNumber: "EI332", duration: "02:15")
                                ]
                            )
                        ]
                    )
                ]
            )
        ]
    }
}
