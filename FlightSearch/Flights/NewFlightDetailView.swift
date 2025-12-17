import SwiftUI

struct NewFlightDetailView: View {
    let flightName: String
    let departureTime: String
    let arrivalTime: String
    let price: String

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(flightName)
                .font(.title)
                .fontWeight(.bold)

            HStack {
                VStack(alignment: .leading) {
                    Text("Departure")
                        .font(.headline)
                    Text(departureTime)
                        .font(.subheadline)
                }

                Spacer()

                VStack(alignment: .leading) {
                    Text("Arrival")
                        .font(.headline)
                    Text(arrivalTime)
                        .font(.subheadline)
                }
            }

            Text("Price: \(price)")
                .font(.headline)
                .foregroundColor(.green)

            Spacer()
        }
        .padding()
        .navigationTitle("Flight Details")
    }
}

struct NewFlightDetailView_Previews: PreviewProvider {
    static var previews: some View {
        NewFlightDetailView(
            flightName: "Flight 123",
            departureTime: "10:00 AM",
            arrivalTime: "12:00 PM",
            price: "$200"
        )
    }
}