import SwiftUI

struct FlightDetailsView: View {
    let flight: Flight
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header Section
                headerSection
                
                // Flight Route Section
                flightRouteSection
                
                // Flight Information Section
                flightInfoSection
                
                // Fare Details Section
                fareDetailsSection
                
                Spacer(minLength: 100)
            }
            .padding(.horizontal, 16)
            .padding(.top, 20)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Text("Flight Details")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(flight.flightNumber)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    private var flightRouteSection: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(flight.departureTime)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(flight.departureAirport)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Image(systemName: "airplane")
                        .foregroundColor(.blue)
                        .font(.title3)
                    
                    Text(flight.duration)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(flight.arrivalTime)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(flight.arrivalAirport)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 20)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    private var flightInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Flight Information")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                FlightInfoRow(title: "Aircraft", value: flight.aircraft)
                FlightInfoRow(title: "Flight Number", value: flight.flightNumber)
                FlightInfoRow(title: "Date", value: flight.date)
                FlightInfoRow(title: "Duration", value: flight.duration)
                if let stops = flight.stops {
                    FlightInfoRow(title: "Stops", value: stops)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
    
    private var fareDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Fare Details")
                .font(.headline)
                .fontWeight(.semibold)
            
            VStack(spacing: 12) {
                FareDetailRow(title: "Base Fare", amount: flight.baseFare)
                FareDetailRow(title: "Taxes & Fees", amount: flight.taxes)
                if let discount = flight.discount {
                    FareDetailRow(title: "Discount", amount: "-\(discount)", isDiscount: true)
                }
                
                Divider()
                
                HStack {
                    Text("Total Amount")
                        .font(.headline)
                        .fontWeight(.bold)
                    Spacer()
                    Text(flight.totalFare)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color(.systemGray4), lineWidth: 1)
            )
        }
    }
}

struct FlightInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct FareDetailRow: View {
    let title: String
    let amount: String
    let isDiscount: Bool
    
    init(title: String, amount: String, isDiscount: Bool = false) {
        self.title = title
        self.amount = amount
        self.isDiscount = isDiscount
    }
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(amount)
                .fontWeight(.medium)
                .foregroundColor(isDiscount ? .green : .primary)
        }
    }
}

// Extension to Flight model to support the new properties
extension Flight {
    var aircraft: String {
        return "Boeing 737-800" // Default value, should come from API
    }
    
    var date: String {
        return "Dec 17, 2024" // Should be formatted from actual date
    }
    
    var baseFare: String {
        return "$299.00" // Should come from fare breakdown
    }
    
    var taxes: String {
        return "$45.00" // Should come from fare breakdown
    }
    
    var discount: String? {
        return nil // Optional discount
    }
    
    var totalFare: String {
        return fare // Using existing fare property
    }
    
    var stops: String? {
        return "Non-stop" // Should come from flight data
    }
}

#Preview {
    FlightDetailsView(flight: Flight(
        id: "1",
        flightNumber: "AA 1234",
        departureTime: "10:30 AM",
        arrivalTime: "2:45 PM",
        duration: "4h 15m",
        fare: "$344.00",
        departureAirport: "JFK",
        arrivalAirport: "LAX"
    ))
}
