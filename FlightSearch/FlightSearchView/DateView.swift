//
//  DateView.swift
//  FlightSearch
//
//  Created by Gowtham on 03/11/2023.
//

import SwiftUI

struct DateView: View {
    @EnvironmentObject var flight: FlightSearch
    @State private var isPresented: Bool = false

    var body: some View {
        Button {
            isPresented.toggle()
        } label: {
            Text("Depature Date: \(flight.fromDate.toString)")
                .customBoarderStyle()
        }
        .sheet(isPresented: $isPresented) {
            SelectDateView(selectedDate: $flight.fromDate, isPresented: $isPresented)
                .navigationBarBackButtonHidden(true)
        }
    }
}

struct SelectDateView: View {
    @Binding var selectedDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    isPresented.toggle()
                } label: {
                    Text("Done")
                }
                .padding()
            }
            
            DatePicker("Select Departure Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .padding()

            Spacer()
        }
        .navigationTitle("Select Date")
    }
}
