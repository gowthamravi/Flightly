//
//  ContentView.swift
//  FlightSearch
//
//  Created by Gowtham on 31/10/2023.
//

import SwiftUI

struct GuestView: View {
    @State private var router = NavigationPath()
    @StateObject private var flight = FlightSearch()
    
    var body: some View {
        NavigationStack(path: $router) {
            VStack(spacing: 30) {
                Spacer()
                    .frame(height: 30)
                Text("Flightly")
                    .font(.custom("Avenir-HeavyOblique", size: 30))
                    .foregroundColor(Color(red: 238/255, green: 119/255, blue: 70/255))
                Spacer()
                    .frame(height: 100)
                Image("banner")
                Spacer()
                Button("Continue") {
                    self.router.append("Continue")
                }
                .buttonStyle(FlightlyButton())
            }
            .navigationDestination(for: String.self) { item in
                MainView()
                    .environmentObject(flight)
                    .navigationBarBackButtonHidden()
            }
           
        } .onAppear {
            flight.start()
        }
    }
}

#Preview {
    GuestView()
}

