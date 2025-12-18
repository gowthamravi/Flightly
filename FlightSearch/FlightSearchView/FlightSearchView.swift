import SwiftUI

struct FlightSearchView: View {
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var departureDate = Date()
    @State private var returnDate = Date().addingTimeInterval(86400)
    @State private var passengers = Passengers()
    @State private var isRoundTrip = false
    @State private var showingStationPicker = false
    @State private var stationPickerType: StationPickerType = .from
    @State private var showingPassengerPicker = false
    @State private var showingDatePicker = false
    @State private var datePickerType: DatePickerType = .departure
    
    enum StationPickerType {
        case from, to
    }
    
    enum DatePickerType {
        case departure, return
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Where would you like to go?")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("Find the best flights for your next adventure")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)
                    
                    // Trip Type Selector
                    VStack(spacing: 16) {
                        HStack(spacing: 0) {
                            Button(action: { isRoundTrip = false }) {
                                Text("One Way")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isRoundTrip ? .secondary : .white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isRoundTrip ? Color.clear : Color.blue)
                                    )
                            }
                            
                            Button(action: { isRoundTrip = true }) {
                                Text("Round Trip")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(isRoundTrip ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isRoundTrip ? Color.blue : Color.clear)
                                    )
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color(.systemGray6))
                        )
                        .padding(.horizontal, 4)
                    }
                    
                    // Flight Search Form
                    VStack(spacing: 16) {
                        // From/To Stations
                        VStack(spacing: 12) {
                            // From Station
                            Button(action: {
                                stationPickerType = .from
                                showingStationPicker = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("From")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(fromStation?.name ?? "Select departure city")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    Image(systemName: "airplane.departure")
                                        .foregroundColor(.blue)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                            }
                            
                            // Swap Button
                            Button(action: swapStations) {
                                Image(systemName: "arrow.up.arrow.down")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.blue)
                                    .frame(width: 32, height: 32)
                                    .background(Circle().fill(Color(.systemGray6)))
                            }
                            
                            // To Station
                            Button(action: {
                                stationPickerType = .to
                                showingStationPicker = true
                            }) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("To")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(toStation?.name ?? "Select destination city")
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                    Spacer()
                                    Image(systemName: "airplane.arrival")
                                        .foregroundColor(.blue)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                            }
                        }
                        
                        // Date Selection
                        HStack(spacing: 12) {
                            // Departure Date
                            Button(action: {
                                datePickerType = .departure
                                showingDatePicker = true
                            }) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Departure")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(departureDate.formatted(date: .abbreviated, time: .omitted))
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color(.systemBackground))
                                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(.systemGray5), lineWidth: 1)
                                )
                            }
                            
                            // Return Date (if round trip)
                            if isRoundTrip {
                                Button(action: {
                                    datePickerType = .return
                                    showingDatePicker = true
                                }) {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Return")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        Text(returnDate.formatted(date: .abbreviated, time: .omitted))
                                            .font(.system(size: 16, weight: .medium))
                                            .foregroundColor(.primary)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding(16)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color(.systemBackground))
                                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(.systemGray5), lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
                        // Passengers
                        Button(action: {
                            showingPassengerPicker = true
                        }) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Passengers")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text("\(passengers.totalCount) Passenger\(passengers.totalCount == 1 ? "" : "s")")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                                Spacer()
                                Image(systemName: "person.2")
                                    .foregroundColor(.blue)
                            }
                            .padding(16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray5), lineWidth: 1)
                            )
                        }
                    }
                    
                    // Search Button
                    NavigationLink(destination: FlightsListView()) {
                        Text("Search Flights")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.blue, Color.blue.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                            )
                            .shadow(color: .blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                    .disabled(!isSearchEnabled)
                    .opacity(isSearchEnabled ? 1.0 : 0.6)
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Flight Search")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingStationPicker) {
            StationListView(selectedStation: stationPickerType == .from ? $fromStation : $toStation)
        }
        .sheet(isPresented: $showingPassengerPicker) {
            PassengerView(passengers: $passengers)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(
                selectedDate: datePickerType == .departure ? $departureDate : $returnDate,
                isPresented: $showingDatePicker,
                title: datePickerType == .departure ? "Select Departure Date" : "Select Return Date"
            )
        }
    }
    
    private var isSearchEnabled: Bool {
        fromStation != nil && toStation != nil
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
}