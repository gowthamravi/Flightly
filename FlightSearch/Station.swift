//
//  Station.swift
//  FlightSearch
//
//  Created by Gowtham on 01/11/2023.
//

import Foundation

struct Station: Codable {
    let code, name, country: String    
}

struct Stations: Codable {
    let stations: [Station]
}
