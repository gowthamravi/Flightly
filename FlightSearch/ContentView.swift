//
//  ContentView.swift
//  FlightSearch
//
//  Created by Norman D on 31/10/2023.
//

import SwiftUI
import ServiceHandler

struct StationListView: View {
    let model: StationListViewModel
    
    var body: some View {
        NavigationStack {
            NavigationLink {
                FlightSearchView(stationLists: model.stationList, 
                                 model: FlightSearchViewModel(
                                    service: FlightSearchService(
                                        service: NetworkService()
                                    )
                                 )
                )
                    .navigationBarBackButtonHidden(true)
            } label: {
                Button("Continue as a Guest") {
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .background(Color.yellow)
                .foregroundStyle(.black)
                .clipShape(Capsule())
            }
            .padding()
        }
        .onAppear {
            Task {
                try await model.fetch()
            }
        }
    }
}
