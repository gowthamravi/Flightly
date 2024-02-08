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
        let queryOrigin = URLQueryItem(name: "origin", value: details.origin?.code ?? "")
        let queryDestination = URLQueryItem(name: "destination", value: details.destination?.code ?? "")
        let queryFromDate = URLQueryItem(name: "dateout", value: details.fromDate.toString)
        
        let returnDate = ""
//        if let date = details.returnDate?.toString {
//            returnDate = date
//        }
        
        let queryReturnDate = URLQueryItem(name: "datein", value: returnDate)
        let queryFlexDaysOut = URLQueryItem(name: "flexdaysbeforeout", value: "3")
        let queryFlexDaysBeforeIn = URLQueryItem(name: "flexdaysbeforein", value: "3")
        let queryFlexDaysIn = URLQueryItem(name: "flexdaysin", value: "3")
        let queryAdults = URLQueryItem(name: "adt", value: "\(details.passengersList.adult)")
        let queryTeen = URLQueryItem(name: "teen", value: "\(details.passengersList.teen)")
        let queryChildren = URLQueryItem(name: "chd", value: "\(details.passengersList.childrens)")
        let queryRoundTrip = URLQueryItem(name: "roundtrip", value: "false")
        let queryToUs = URLQueryItem(name: "ToUs", value: "AGREED")
        let queryToDisc = URLQueryItem(name: "Disc", value: "0")

        urlComponents.queryItems = [queryOrigin,
                                    queryDestination,
                                    queryFromDate,
                                    queryReturnDate,
                                    queryFlexDaysOut,
                                    queryFlexDaysBeforeIn,
                                    queryFlexDaysIn, 
                                    queryAdults,
                                    queryTeen,
                                    queryChildren,
                                    queryRoundTrip,
                                    queryToUs,
                                    queryToDisc]
        
        guard let url = urlComponents.url else { return nil }
        self = url
    }
}
