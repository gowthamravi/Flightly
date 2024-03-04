//
//  StationListView.swift
//  FlightSearch
//
//  Created by Gowtham on 04/11/2023.
//

import SwiftUI

struct StationListView: View {
    @EnvironmentObject private var flight: FlightSearch
    @Binding var isPresented: Bool
    let stationType: StationType
    @State private var searchText = ""
    
    var body: some View {
        
        let list = stationLists
        
        NavigationStack {
            List(list.keys.sorted(), id: \.self) { key in
                let station = list[key]
                
                Button {
                    if stationType == .origin {
                        flight.origin = station!
                        //                            flight.destination = nil
                    } else {
                        flight.destination = station!
                    }
                    isPresented.toggle()
                } label: {
                    StationRow(station: station)
                }
                .padding()
            }
            .searchable(text: $searchText)
            .navigationTitle("Choose Departure")
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var stationLists: [String: Station] {
        var list = flight.allStations
        if !searchText.isEmpty {
            list = list.filter{ (key: String, value: Station) in
                value.country.lowercased().contains(searchText.lowercased()) ||  value.code.lowercased().contains(searchText.lowercased()) || value.name.lowercased().contains(searchText.lowercased())
            }
        }
        return list
    }
}
