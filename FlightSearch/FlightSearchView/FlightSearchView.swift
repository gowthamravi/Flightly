import SwiftUI

struct FlightSearchView: View {
    @StateObject private var viewModel = FlightSearchViewModel()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Select Route")) {
                    StationView(station: $viewModel.origin, placeholder: "Origin")
                    
                    HStack {
                        Spacer()
                        Button(action: viewModel.swapOriginDestination) {
                            Image(systemName: "arrow.up.arrow.down.circle.fill")
                                .font(.title2)
                        }
                        .buttonStyle(.plain)
                        Spacer()
                    }
                    
                    StationView(station: $viewModel.destination, placeholder: "Destination")
                }
                
                Section(header: Text("Select Date")) {
                    DateView(selectedDate: $viewModel.journeyDate)
                }
                
                Section(header: Text("Passengers")) {
                    PassengerView(passengers: $viewModel.passengers)
                }
                
                RecentSearchesView(
                    recentSearches: viewModel.recentSearches,
                    onSearchSelected: viewModel.selectRecentSearch,
                    onClearAll: viewModel.clearRecentSearches
                )
                
                Section {
                    Button(action: viewModel.performSearch) {
                        Text("Search Flights")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Flight Search")
        }
    }
}

struct FlightSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView()
    }
}
