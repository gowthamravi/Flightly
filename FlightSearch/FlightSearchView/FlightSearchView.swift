import SwiftUI

struct FlightSearchView: View {
    @State private var departureStation: String = ""
    @State private var arrivalStation: String = ""
    @State private var departureDate: Date = Date()
    @State private var returnDate: Date = Date()
    @State private var isRoundTrip: Bool = false

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                StationView(stationName: $departureStation, placeholder: "Departure")
                StationView(stationName: $arrivalStation, placeholder: "Arrival")

                DateView(date: $departureDate, title: "Departure Date")

                if isRoundTrip {
                    DateView(date: $returnDate, title: "Return Date")
                }

                Toggle("Round Trip", isOn: $isRoundTrip)
                    .toggleStyle(SwitchToggleStyle(tint: .blue))

                NavigationLink(destination: PassengerView()) {
                    Text("Search Flights")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
            .navigationTitle("Flight Search")
        }
    }
}

struct FlightSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView()
    }
}