//
//  FlightSearchView.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import SwiftUI
import ServiceHandler
import ActivityIndicatorView

struct FlightSearchView: View {
    @Environment(FlightSearch.self) private var flight
    @State private var showLoadingIndicator: Bool = false

    var body: some View {
        ZStack {

        VStack(spacing: 20) {
                StationView(stationType: .origin)
                StationView(stationType: .destination)
                
                DateView(flight: flight)
                PassengerView(flight: flight)
                
                Spacer()
                
                LetsGoView(showLoadingIndicator: $showLoadingIndicator)
            }
            if showLoadingIndicator {
                ActivityIndicatorView(isVisible: $showLoadingIndicator, type: .default())
                    .frame(width: 40, height: 40)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Flight Search")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
