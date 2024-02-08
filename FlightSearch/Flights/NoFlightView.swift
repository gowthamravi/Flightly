//
//  NoFlightView.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI

struct NoFlightView: View {
    @Binding var isPresented: Bool

    var body: some View {
        ContentUnavailableView(label: {
            Label("Oops!", systemImage: "airplane.arrival")
        }, description: {
            Text("No Flights for the selected date. \n Please select a different Date")
        }, actions: {
            Button {
                isPresented.toggle()
            } label: {
                Text("Go back")
                    .customBoarderStyle()
            }
        })
        .navigationBarBackButtonHidden(true)
    }
}
