import SwiftUI

struct FlightsListView: View {
    let origin: Station
    let destination: Station
    let passengers: Passengers
    let trips: [Trip]
    
    private var passengerSummary: String {
        var parts: [String] = []
        if passengers.adults > 0 {
            parts.append("\(passengers.adults) Adult" + (passengers.adults > 1 ? "s" : ""))
        }
        if passengers.teens > 0 {
            parts.append("\(passengers.teens) Teen" + (passengers.teens > 1 ? "s" : ""))
        }
        if passengers.children > 0 {
            parts.append("\(passengers.children) " + (passengers.children > 1 ? "Children" : "Child"))
        }
        return parts.joined(separator: ", ")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all)
                
                if trips.isEmpty {
                    NoFlightView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            headerView
                                .padding(.horizontal)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(trips) { trip in
                                    FlightRow(trip: trip)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top)
                    }
                }
            }
            .navigationTitle("Available Flights")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading) {
            Text("\(origin.name) (\(origin.code)) to \(destination.name) (\(destination.code))")
                .font(.title3)
                .fontWeight(.bold)
            
            Text(passengerSummary)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

struct FlightsListView_Previews: PreviewProvider {
    static var previews: some View {
        let mockOrigin = Station(code: "DUB", name: "Dublin", country: "Ireland")
        let mockDestination = Station(code: "BER", name: "Berlin", country: "Germany")
        let mockPassengers = Passengers(adults: 1, teens: 0, children: 2)
        
        FlightsListView(
            origin: mockOrigin,
            destination: mockDestination,
            passengers: mockPassengers,
            trips: Trip.mockTrips
        )
        .previewDisplayName("With Flights")
        
        FlightsListView(
            origin: mockOrigin,
            destination: mockDestination,
            passengers: mockPassengers,
            trips: []
        )
        .previewDisplayName("No Flights")
    }
}
