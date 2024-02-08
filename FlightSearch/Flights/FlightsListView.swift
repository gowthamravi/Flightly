//
//  FlightsListView.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI

struct FlightsListView: View {
    let flightDates: [DateElement]
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack {
            let flights = flightDates[0].flights
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

                GeometryReader { geometry in
                    ScrollView(.horizontal, showsIndicators: true) {
                        LazyHStack {
                            ForEach(flightDates) { date in
                                VStack {
                                    Text("<-- \(date.dateOut.toMMMddYYYY) --> ")
                                        .padding()
                                    List(date.flights) { flight in
                                        FlightRow(flight: flight)
                                    }
                                    .frame(width: geometry.size.width, height: geometry.size.height - 100)
                                }
                            }
                        }
                    }
                    .scrollTargetBehavior(.paging)
                }
            }
        }
    }
}
