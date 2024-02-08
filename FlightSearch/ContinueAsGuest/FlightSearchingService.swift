//
//  FlightSearchService.swift
//  FlightSearch
//
//  Created by Gowtham on 02/11/2023.
//

import Foundation
import ServiceHandler

protocol FlightSearching {
    func fetchStations() async throws -> Stations
    func searchFlight(details: FlightSearch) async throws -> FlightSearchResponse
}

class FlightSearchingService: FlightSearching {
    private let service: NetworkServiable

    init(service: NetworkServiable) {
        self.service = service
    }

    func fetchStations() async throws -> Stations {
        try await service.fetch(request: Requests.AirportStation.lists())
    }
    
    func searchFlight(details: FlightSearch) async throws -> FlightSearchResponse {
        try await service.fetch(request: Requests.FlightSearchAPI.searchFlight(details: details))
    }
}
