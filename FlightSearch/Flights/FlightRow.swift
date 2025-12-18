import SwiftUI

struct FlightRow: View {
    let trip: Trip
    
    private let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }()
    
    private let isoFormatter = ISO8601DateFormatter()

    private func formatTime(from dateString: String?) -> String {
        guard let dateString = dateString, let date = isoFormatter.date(from: dateString) else {
            return "--:--"
        }
        return timeFormatter.string(from: date)
    }

    var body: some View {
        if let flight = trip.firstFlight {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 12) {
                    flightTimesView(flight)
                    airlineInfoView(flight)
                }
                
                Spacer()
                
                if let fare = trip.totalFare {
                    FareView(fare: fare) {
                        print("Selected flight \(flight.flightNumber) for €\(fare)")
                    }
                    .frame(width: 100)
                }
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        } else {
            EmptyView()
        }
    }
    
    private func flightTimesView(_ flight: Flight) -> some View {
        HStack(spacing: 8) {
            Text(formatTime(from: flight.departureTime))
                .font(.headline)
                .fontWeight(.bold)
            
            Image(systemName: "arrow.right")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(formatTime(from: flight.arrivalTime))
                .font(.headline)
                .fontWeight(.bold)
        }
    }
    
    private func airlineInfoView(_ flight: Flight) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "airplane.circle.fill")
                .font(.title2)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading) {
                Text(flight.airline?.name ?? "Unknown Airline")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(flight.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct FlightRow_Previews: PreviewProvider {
    static var previews: some View {
        FlightRow(trip: Trip.mock)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
