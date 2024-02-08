//
//  Trips.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import Foundation

// MARK: - FlightSearchResponse
struct FlightSearchResponse: Decodable {
    let trips: [Trip]?
}

// MARK: - Trip
struct Trip: Decodable {
    let dates: [DateElement]
}

// MARK: - DateElement
struct DateElement: Identifiable, Decodable {
    let id = UUID()
    let dateOut: String
    let flights: [Flight]
    private enum CodingKeys: CodingKey {
        case flights, dateOut
    }
}

// MARK: - Flight
struct Flight: Identifiable, Decodable {
    let id = UUID()
    let regularFare: RegularFare
    let segments: [Segment]
    let flightNumber: String
    let duration: String
    let timeUTC: [String]
    private enum CodingKeys: CodingKey {
        case regularFare
        case segments
        case flightNumber
        case duration
        case timeUTC
    }
}

// MARK: - RegularFare
struct RegularFare: Decodable {
    let fareClass: String
    let fares: [Fare]
}

// MARK: - Fare
struct Fare: Identifiable, Decodable {
    let id = UUID()
    let type: String
    let amount: Double
    
    private enum CodingKeys: CodingKey {
        case type
        case amount
    }
}

// MARK: - Segment
struct Segment: Decodable {
    let segmentNr: Int
    let origin: String
    let destination: String
    let flightNumber: String
    let timeUTC: [String]
    let duration: String
}
