//
//  URL+Extension.swift
//  FlightSearch
//
//  Created by Gowtham on 01/11/2023.
//

import Foundation

extension URL {
    init?(baseURL: URL, path: String) {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return nil }
        urlComponents.path = path
        guard let url = urlComponents.url else { return nil }
        self = url
    }
    
    init?(baseURL: URL, details: FlightSearch) {
        guard var urlComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true) else { return nil }
        let queryOrigin = URLQueryItem(name: "fromId", value: details.origin?.code)
        let queryDestination = URLQueryItem(name: "toId", value: details.destination?.code)
        let queryFromDate = URLQueryItem(name: "departureDate", value: details.fromDate.toString)
        let currentPage = URLQueryItem(name: "page", value: "1")
        urlComponents.queryItems = [queryOrigin,
                                    queryDestination,
                                    queryFromDate,
                                    currentPage
        ]
        
        guard let url = urlComponents.url else { return nil }
        self = url
    }
}
