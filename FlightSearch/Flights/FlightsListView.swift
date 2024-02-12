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
                
                

//                GeometryReader { geometry in
//                    ScrollView(.horizontal, showsIndicators: true) {
//                        LazyHStack {
//                                          
//                            ForEach(flight) { data in
//                                HStack {
//                                    Text((data.bounds?[0].segments?[0].operatingCarrier?.name!)!)
//                                    Text((data.bounds?[0].segments?[0].flightNumber!)!)
//                                    Text((data.bounds?[0].segments?[0].departuredAt!.toUTCToLocal)!)
//                                    .frame(width: geometry.size.width, height: geometry.size.height - 100)
//                                }
//                            }
//            
////                            ForEach(flights) { date in
////                                VStack {
////                                    Text("<-- \(date.dateOut.toMMMddYYYY) --> ")
////                                        .padding()
////                                    List(date.flights) { flight in
////                                        FlightRow(flight: flight)
////                                    }
////                                    .frame(width: geometry.size.width, height: geometry.size.height - 100)
////                                }
////                            }
//                        }
//                    }
//                    .scrollTargetBehavior(.paging)
//                }
            }
        }
    }
}
