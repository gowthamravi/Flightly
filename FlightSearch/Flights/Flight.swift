import Foundation

struct Flight: Identifiable, Codable {
    let id: String
    let flightNumber: String
    let departureTime: String
    let arrivalTime: String
    let duration: String
    let fare: String
    let departureAirport: String
    let arrivalAirport: String
    
    // Additional properties for flight details
    let aircraftType: String?
    let departureDate: Date?
    let arrivalDate: Date?
    let baseFareAmount: Double?
    let taxesAmount: Double?
    let discountAmount: Double?
    let totalFareAmount: Double?
    let numberOfStops: Int?
    let stopAirports: [String]?
    
    init(id: String, flightNumber: String, departureTime: String, arrivalTime: String, duration: String, fare: String, departureAirport: String, arrivalAirport: String, aircraftType: String? = nil, departureDate: Date? = nil, arrivalDate: Date? = nil, baseFareAmount: Double? = nil, taxesAmount: Double? = nil, discountAmount: Double? = nil, totalFareAmount: Double? = nil, numberOfStops: Int? = nil, stopAirports: [String]? = nil) {
        self.id = id
        self.flightNumber = flightNumber
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.duration = duration
        self.fare = fare
        self.departureAirport = departureAirport
        self.arrivalAirport = arrivalAirport
        self.aircraftType = aircraftType
        self.departureDate = departureDate
        self.arrivalDate = arrivalDate
        self.baseFareAmount = baseFareAmount
        self.taxesAmount = taxesAmount
        self.discountAmount = discountAmount
        self.totalFareAmount = totalFareAmount
        self.numberOfStops = numberOfStops
        self.stopAirports = stopAirports
    }
}

// MARK: - Sample Data
extension Flight {
    static let sampleFlights: [Flight] = [
        Flight(
            id: "1",
            flightNumber: "AA 1234",
            departureTime: "10:30 AM",
            arrivalTime: "2:45 PM",
            duration: "4h 15m",
            fare: "$344.00",
            departureAirport: "JFK",
            arrivalAirport: "LAX",
            aircraftType: "Boeing 737-800",
            baseFareAmount: 299.00,
            taxesAmount: 45.00,
            totalFareAmount: 344.00,
            numberOfStops: 0
        ),
        Flight(
            id: "2",
            flightNumber: "DL 5678",
            departureTime: "6:15 AM",
            arrivalTime: "11:30 AM",
            duration: "5h 15m",
            fare: "$289.00",
            departureAirport: "JFK",
            arrivalAirport: "LAX",
            aircraftType: "Airbus A320",
            baseFareAmount: 249.00,
            taxesAmount: 40.00,
            totalFareAmount: 289.00,
            numberOfStops: 1,
            stopAirports: ["DEN"]
        )
    ]
}