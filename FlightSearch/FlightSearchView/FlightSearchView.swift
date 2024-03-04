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
    @EnvironmentObject private var flight: FlightSearch
    @EnvironmentObject private var router: Router
    @State private var showLoadingIndicator: Bool = false
    
    var body: some View {
        NavigationStack(path: $router.path) {
            
            VStack(alignment: .leading) {
                Text("Let's")
                    .font(.title2)
                    .frame(alignment: .leading)
                Text("Explore")
                    .font(.title)
                    .frame(alignment: .leading)
            } .frame(maxWidth: .infinity, alignment: .topLeading)
            VStack(alignment: .leading, spacing: 20) {

                StationView(stationType: .origin)
                StationView(stationType: .destination)
                
                DateView()
                    .environmentObject(flight)
                PassengerView()
                    .environmentObject(flight)
                
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

#Preview {
    FlightSearchView()
        .environmentObject(FlightSearch(service: FlightSearchingService(service: NetworkService())))
        .environmentObject(Router.shared)
}
