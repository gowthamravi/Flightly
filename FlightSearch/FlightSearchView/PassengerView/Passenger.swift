//
//  Passenger.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI

struct Passenger: View {
    let title: String
    let subTitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            Text(subTitle)
                .font(.subheadline)
                .foregroundStyle(.gray)
        }
    }
}
