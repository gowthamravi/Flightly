//
//  PassengerView.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import SwiftUI

struct PassengerView: View {
    @State private var isPresented: Bool = false
    @EnvironmentObject var flight: FlightSearch
    
    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Text("Passengers: \(passengerText())")
                .customBoarderStyle()
        }
        .sheet(isPresented: $isPresented) {
            Passengers(isPresented: $isPresented, passengerList: $flight.passengersList)
                .navigationBarBackButtonHidden(true)
        }
    }
    
    private func passengerText() -> String {
        var passengers: String = ""
        let adultCount = flight.passengersList.adult
        let teenCount = flight.passengersList.teen
        let childrenCount = flight.passengersList.childrens
        let infantsCount = flight.passengersList.infants
        
        if adultCount > 0 {
            passengers += "Adults - \(adultCount)"
        }
        if teenCount > 0 {
            passengers += ", Teens - \(teenCount)"
        }
        if childrenCount > 0 {
            passengers += ", Children - \(childrenCount)"
        }
        if infantsCount > 0 {
            passengers += ", Infants - \(infantsCount)"
        }

        return passengers
    }
}
