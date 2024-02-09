//
//  Trips.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import Foundation

struct FlightSearchResponse : Codable {
    let data : Datas?
    let meta : Meta?
    let status : Bool?
    let message : String?
}

struct Datas : Codable {
    let flights : [Flights]?
}

struct Flights : Identifiable, Codable {
    let id = UUID()
    let tempId: String?
    let bounds : [Bounds]?
    
    enum CodingKeys: String, CodingKey {
        case tempId = "id"
        case bounds
    }
}

struct Bounds : Codable {
    let boundId : String?
    let segments : [Segments]?
}

struct IncludedCabinBaggage : Codable {
    let pieces : Int?
    let weight : Int?
    let weightUnit : String?
}
struct IncludedCheckedBaggage : Codable {
    let pieces : Int?
    let weight : Int?
    let weightUnit : String?
}

struct OperatingCarrier : Codable {
    let code : String?
    let name : String?
}

struct Destination : Codable {
    let code : String?
    let name : String?
    let cityCode : String?
    let cityName : String?
    let airportCode : String?
    let airportName : String?
}

struct Segments : Codable {
    let segmentId : String?
    let origin : Origin?
    let destination : Destination?
    let arrivedAt : String?
    let departuredAt : String?
    let includedCabinBaggage : IncludedCabinBaggage?
    let includedCheckedBaggage : IncludedCheckedBaggage?
    let flightNumber : String?
    let cabinClassName : String?
    let numberOfTechnicalStops : Int?
    let duration : Int?
    let operatingCarrier : OperatingCarrier?
}

struct Origin : Codable {
    let code : String?
    let name : String?
    let cityCode : String?
    let cityName : String?
    let airportCode : String?
    let airportName : String?
}

struct Meta : Codable {
    let currentPage : Int?
    let limit : Int?
    let totalRecords : Int?
    let totalPage : Int?
}
