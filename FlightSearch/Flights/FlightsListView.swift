//
//  FlightsListView.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI

struct FlightsListView: View {
    let flights: [Flights]
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            let flight = flights
            if flights.isEmpty {
                NoFlightView(isPresented: $isPresented)
            } else {
                HStack {
                    Spacer()
                    Button {
                        isPresented.toggle()
                    } label: {
                        Text("Done")
                    }
                    .padding()
                }
                
                List(flight) { data in
                    VStack {
                        HStack {
                            Text((data.bounds?[0].segments?[0].operatingCarrier?.name!)!)
                            Text("-->")
                            Text((data.bounds?[0].segments?[0].flightNumber!)!)
                        }
                        Text((data.bounds?[0].segments?[0].departuredAt!.toMMMddYYYY)!)
                    }
                }
                
            }
        }
    }
}
