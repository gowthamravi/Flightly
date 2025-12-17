import SwiftUI

struct FlightSearchView: View {
    @State private var departure: String = ""
    @State private var destination: String = ""
    @State private var travelDate: Date = Date()
    @State private var passengerCount: Int = 1

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Departure", text: $departure)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                TextField("Destination", text: $destination)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                DatePicker("Travel Date", selection: $travelDate, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Stepper(value: $passengerCount, in: 1...10) {
                    Text("Passengers: \(passengerCount)")
                }
                .padding()

                Button(action: {
                    print("Search Flights")
                }) {
                    Text("Search Flights")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()

                Spacer()
            }
            .navigationTitle("Flight Search")
            .padding()
        }
    }
}

struct FlightSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView()
    }
}