import SwiftUI

struct FlightSearchView: View {
    @State private var departureDate: Date = Date()
    @State private var returnDate: Date = Date()
    @State private var isRoundTrip: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            Toggle("Round Trip", isOn: $isRoundTrip)
                .padding()

            DatePicker("Departure Date", selection: $departureDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()

            if isRoundTrip {
                DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()
            }

            Button(action: {
                searchFlights()
            }) {
                Text("Search Flights")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding()
        }
        .padding()
        .navigationTitle("Flight Search")
    }

    private func searchFlights() {
        // Logic for searching flights based on the selected dates and trip type
        print("Searching flights for departure: \(departureDate) and return: \(isRoundTrip ? returnDate : nil)")
    }
}

struct FlightSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView()
    }
}