//
//  ContentView.swift
//  FlightSearch
//
//  Created by Gowtham on 31/10/2023.
//

import SwiftUI

struct GuestView: View {
    @State private var flight = FlightSearch()
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                FlightSearchView()
                    .environment(flight)
                    .navigationBarBackButtonHidden(true)
            } label: {
                Button("") {
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .center)
                .background(Color.yellow)
                .foregroundStyle(.black)
                .clipShape(Capsule())
                .overlay {
                    Text("Continue as a Guest")
                        .foregroundStyle(.black)
                }
            }
            .padding()
        }
        .onAppear {
            flight.start()
        }
    }
}
