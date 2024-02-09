//
//  LetsGoView.swift
//  FlightSearch
//
//  Created by Gowtham on 04/11/2023.
//

import SwiftUI
import ServiceHandler

struct LetsGoView: View {
    @Environment(FlightSearch.self) private var flightSearch
    @State private var isPresented: Bool = false
    @State private var isErrorPresented: Bool = false

    var body: some View {
        Button {
            Task {
                do {
                    try await flightSearch.searchFlight()
                    isPresented.toggle()
                } catch {
                    isErrorPresented.toggle()
                }
            }
        } label: {
            Text("Let's go")
                .customBoarderStyle()
        }
        .sheet(isPresented: $isPresented) {
            FlightsListView(flights: flightSearch.flights, isPresented: $isPresented)
        }
        .sheet(isPresented: $isErrorPresented) {
            ContentUnAvailableCustomView(isPresented: $isErrorPresented)
        }
    }
}

