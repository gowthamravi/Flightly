//
//  FlightSearchView.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import SwiftUI
import ServiceHandler

struct FlightSearchView: View {
    @Environment(FlightSearch.self) private var flight

    var body: some View {
        VStack(spacing: 20) {
                        
            StationView(stationType: .origin)
            StationView(stationType: .destination)
            
            DateView(flight: flight)
            PassengerView(flight: flight)
            
            Spacer()
            
            LetsGoView()
        }
        .navigationTitle("Flight Search")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
