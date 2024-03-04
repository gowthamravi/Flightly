//
//  MainView.swift
//  FlightSearch
//
//  Created by Gowtham R on 29/02/24.
//

import SwiftUI
import ServiceHandler

struct MainView: View {
    @EnvironmentObject var flight: FlightSearch
    @StateObject private var router = Router.shared
    var body: some View {
        TabView {
            FlightSearchView()
                .environmentObject(flight)
                .environmentObject(router)
                .tabItem {
                    Label(
                        title: {  },
                        icon: { Image(systemName: "house") }
                    )
                }
            FavouriteView()
                .tabItem {
                    Label(
                        title: { },
                        icon: { Image(systemName: "suit.heart") }
                    )
                }
            FavouriteView()
                .tabItem {
                    Label(
                        title: { },
                        icon: { Image(systemName: "person.crop.circle") }
                    )
                }
        }
    }
}

#Preview {
    MainView()
        .environmentObject(FlightSearch(service: FlightSearchingService(service: NetworkService())))
}
