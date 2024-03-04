//
//  StationListViewModel.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import Foundation
import ServiceHandler

class FlightSearch: ObservableObject {
    var allStations: [String: Station] = [:]
    @Published var origin: Station?
    @Published var destination: Station?
    var fromDate: Date = Date()
    var passengersList: (adult: Int, teen: Int, childrens: Int, infants: Int) = (1, 0, 0, 0)
    var flights: [Flights] = []
    
    private let service: FlightSearching
    
    init(service: FlightSearchingService = FlightSearchingService(service: NetworkService())) {
        self.service = service
    }
    
    func start() {
        
        guard let path = Bundle.main.path(forResource: "airport", ofType: "json") else {
            return
        }
        
        do {
            let fileUrl = URL(fileURLWithPath: path)
            let data = try Data(contentsOf: fileUrl)
            let stations = try JSONDecoder().decode([Station].self, from: data)
            for station in stations {
                allStations[station.code] = station
            }
        } catch {
            print(error)
        }
        
        //        let data = try Data(contentsOf: path)
        //        let result = try JSONDecoder().decode(Stations.self, from: data)
        //        for station in stations.stations {
        //            allStations[station.code] = station
        //        }
        //        Task {
        //            let stations = try await service.fetchStations()
        //
        //
        //        }
    }
    
    func searchFlight() async throws {
        do {
            let response = try await service.searchFlight(details: self)
            flights = response.data?.flights ?? []
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

