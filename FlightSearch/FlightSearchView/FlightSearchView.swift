import SwiftUI

struct FlightSearchView: View {
    @State private var departureStation: String = ""
    @State private var arrivalStation: String = ""
    @State private var departureDate: Date = Date()
    @State private var passengerCount: Int = 1

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                StationView(title: "Departure", station: $departureStation)
                StationView(title: "Arrival", station: $arrivalStation)

                DateView(selectedDate: $departureDate)

                PassengerView(passengerCount: $passengerCount)

                Button(action: {
                    // Handle search action
                }) {
                    Text("Search Flights")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)

                Spacer()
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