//
//  ApiConstants.swift
//  FlightSearch
//
//  Created by Gowtham on 01/11/2023.
//

import Foundation
import SwiftSyntaxMacros
import SwiftMacros

struct BaseURL {
    static let stationList = #URL("https://mobile-testassets-dev.s3.eu-west-1.amazonaws.com")
    static let flightSearch = #URL("https://nativeapps.ryanair.com/api/v4/Availability")
    static let oneWaySearch = #URL("https://booking-com18.p.rapidapi.com/flights/search-oneway?")
    
}
