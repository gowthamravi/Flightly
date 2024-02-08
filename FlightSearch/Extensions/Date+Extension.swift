//
//  Date+Extension.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import Foundation

extension Date {
    var toString: String {
        let formatter = DateFormatter()
        let format: String = "yyyy-MM-dd"
        formatter.dateStyle = .short
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
}
