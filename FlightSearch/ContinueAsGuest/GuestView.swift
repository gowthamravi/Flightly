//
//  ContentView.swift
//  FlightSearch
//
//  Created by Gowtham on 31/10/2023.
//

import SwiftUI

struct GuestView: View {
    @StateObject private var router = Router.shared
    @State private var flight = FlightSearch()
    
    var body: some View {
        NavigationStack(path: $router.path) {
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
                    router.path.append("Continue")
                }
                .frame(height: 50)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .background(Color(red: 238/255, green: 119/255, blue: 70/255))
                .clipShape(Capsule())
                .font(.custom("Avenir-HeavyOblique", size: 20))
                .padding()
            }
            .navigationDestination(for: String.self) { item in
                FlightSearchView()
                    .environment(flight)
            }
        } .onAppear {
            flight.start()
        }
    }
}

#Preview {
    GuestView()
}

