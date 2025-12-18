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
        NavigationView {
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
                        NavigationLink(destination: FlightDetailsView(flight: createFlight(from: data))) {
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
    }
    
    private func createFlight(from data: Flights) -> Flight {
        let segment = data.bounds?.first?.segments?.first
        let flightNumber = segment?.flightNumber ?? ""
        let departureTime = segment?.departuredAt?.toMMMddYYYY ?? ""
        let arrivalTime = segment?.arrivedAt?.toMMMddYYYY ?? ""
        let durationMin = segment?.duration ?? 0
        let duration = "\(durationMin / 60)h \(durationMin % 60)m"
        
        return Flight(
            id: data.tempId ?? UUID().uuidString,
            flightNumber: flightNumber,
            departureTime: departureTime,
            arrivalTime: arrivalTime,
            duration: duration,
            fare: "$0",
            departureAirport: segment?.origin?.code ?? "",
            arrivalAirport: segment?.destination?.code ?? ""
        )
    }
}
