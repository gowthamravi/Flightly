//
//  Requests.swift
//  FlightSearch
//
//  Created by Gowtham on 01/11/2023.
//

import Foundation
import ServiceHandler


struct Header {
    static let headers = [
        "X-RapidAPI-Key": "48c3fabb4amsh6fd9f268c936b86p1bb588jsn29b532172b95",
        "X-RapidAPI-Host": "booking-com18.p.rapidapi.com"
    ]
}
struct Requests {
    struct AirportStation {
        static func lists() -> Request<Stations> {
            .init(
                url: .init(
                    baseURL: BaseURL.stationList,
                    path: "/stations.json"
                )!,
                httpMethod: .get, header: nil
            )
        }
    }
    
    struct FlightSearchAPI {
        static func searchFlight(details: FlightSearch) -> Request<FlightSearchResponse> {
            .init(
                url: .init(baseURL: BaseURL.oneWaySearch, details: details)!,
                httpMethod: .get,
                header: Header.headers
            )
        }
    }
}
