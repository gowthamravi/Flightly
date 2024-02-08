//
//  Passengers.swift
//  FlightSearch
//
//  Created by Gowtham on 05/11/2023.
//

import SwiftUI


struct Passengers: View {
    @State private var adults: Int = 1
    @State private var teens: Int = 0
    @State private var childerns: Int = 0
    @State private var infants: Int = 0
    @Binding var isPresented: Bool
    @Binding var passengerList: (adult: Int, teen: Int, childrens: Int, infants: Int)

    @Environment(\.presentationMode) var presentation

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    passengerList = (adults, teens, childerns, infants)
                    isPresented.toggle()
                } label: {
                    Text("Done")
                }
                .padding()
            }
            
            StepperView(value: $adults) {
                Passenger(title: "Adults", subTitle: "16+ years")
            }
            StepperView(value: $teens) {
                Passenger(title: "Teens", subTitle: "12-15 years")
            }
            StepperView(value: $childerns) {
                Passenger(title: "Childern", subTitle: "2-11 years")
            }
            StepperView(value: $infants) {
                Passenger(title: "Infants", subTitle: "Under 2")
            }
            
            Spacer()
        }
        .navigationTitle("Passengers")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding()
    }
}
