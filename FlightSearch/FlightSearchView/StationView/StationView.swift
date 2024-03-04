//
//  StationView.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import SwiftUI

enum StationType {
    case origin
    case destination
}

struct StationView: View {
    let stationType: StationType
    @State private var isPresented: Bool = false
    @EnvironmentObject private var flight: FlightSearch    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Text(stationType == .origin ?
                 "From: \(flight.origin?.code ?? "")" :
                  "To: \(flight.destination?.code ?? "")")
            .customBoarderStyle()
        }
        .sheet(isPresented: $isPresented) {
            StationListView(isPresented: $isPresented, stationType: stationType)
                .environmentObject(flight)
        }
    }
}
