//
//  LetsGoView.swift
//  FlightSearch
//
//  Created by Gowtham on 04/11/2023.
//

import SwiftUI
import ServiceHandler
import ActivityIndicatorView

struct LetsGoView: View {
    @EnvironmentObject private var flight: FlightSearch
    @State private var isPresented: Bool = false
    @State private var isErrorPresented: Bool = false
    @Binding var showLoadingIndicator: Bool
    
    var body: some View {
        
        ZStack {
        Button {
                Task {
                    do {
                        showLoadingIndicator.toggle()
                        try await flight.searchFlight()
                        isPresented.toggle()
                        showLoadingIndicator.toggle()
                    } catch {
                        isErrorPresented.toggle()
                    }
                }
            } label: {
                Text("Let's go")
                    .customBoarderStyle()
            }
            .sheet(isPresented: $isPresented) {
                FlightsListView(flights: flight.flights, isPresented: $isPresented)
            }
            .sheet(isPresented: $isErrorPresented) {
                ContentUnAvailableCustomView(isPresented: $isErrorPresented)
            }
           
        }
        
    }
}

struct Animation: View {
    @State private var showLoadingIndicator: Bool = true
    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size.width / 5
            let spacing: CGFloat = 40.0
            
            VStack {
                HStack {
                    Spacer()
                    VStack(spacing: spacing) {
                        Spacer()
                   
                        Spacer()
                    }
                }
            }
        }
    }
    
}
