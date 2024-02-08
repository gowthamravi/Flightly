//
//  Station.swift
//  FlightSearch
//
//  Created by Gowtham on 01/11/2023.
//

import Foundation

struct Station: Decodable {
    let code, name: String
    let countryName: String
    let markets: [Market]?
    let tripCardImageURL: String?
    
    struct Market: Decodable {
        let code: String
        let group: String?
    }
}

struct Stations: Decodable {
    let stations: [Station]
}
