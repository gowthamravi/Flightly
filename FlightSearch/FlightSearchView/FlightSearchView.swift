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
    @State private var showingPassengerView = false
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
                    headerSection
                    
                    VStack(spacing: 16) {
                        tripTypeSelector
                        stationSelectionCard
                        dateSelectionCard
                        passengerSelectionCard
                        searchButton
                    }
                    .padding(.horizontal, 20)
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStationPicker) {
            StationListView(selectedStation: stationPickerType == .from ? $fromStation : $toStation)
        }
        .sheet(isPresented: $showingPassengerView) {
            PassengerView(passengers: $passengers)
        }
        .sheet(isPresented: $showingDatePicker) {
            DatePickerView(selectedDate: datePickerType == .departure ? $departureDate : $returnDate, title: datePickerType == .departure ? "Departure Date" : "Return Date")
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Where to?")
                    .font(.system(size: 28, weight: .bold, design: .default))
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            HStack {
                Text("Find the best flights for your next adventure")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.clear]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
    
    private var tripTypeSelector: some View {
        HStack(spacing: 0) {
            Button(action: { isRoundTrip = false }) {
                Text("One Way")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isRoundTrip ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isRoundTrip ? Color.clear : Color.blue)
            }
            
            Button(action: { isRoundTrip = true }) {
                Text("Round Trip")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isRoundTrip ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(isRoundTrip ? Color.blue : Color.clear)
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(.systemGray4), lineWidth: 1)
        )
    }
    
    private var stationSelectionCard: some View {
        VStack(spacing: 0) {
            // From Station
            Button(action: {
                stationPickerType = .from
                showingStationPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("From")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let fromStation = fromStation {
                            Text(fromStation.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(fromStation.code)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Select departure city")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "airplane.departure")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .padding(16)
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Swap Button
            HStack {
                Spacer()
                Button(action: swapStations) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(Circle())
                }
                Spacer()
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, 16)
            
            // To Station
            Button(action: {
                stationPickerType = .to
                showingStationPicker = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("To")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        if let toStation = toStation {
                            Text(toStation.name)
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(.primary)
                            Text(toStation.code)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(.secondary)
                        } else {
                            Text("Select destination city")
                                .font(.system(size: 18, weight: .regular))
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "airplane.arrival")
                        .font(.system(size: 20))
                        .foregroundColor(.blue)
                }
                .padding(16)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var dateSelectionCard: some View {
        HStack(spacing: 0) {
            // Departure Date
            Button(action: {
                datePickerType = .departure
                showingDatePicker = true
            }) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Departure")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(departureDate.formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(departureDate.formatted(.dateTime.month(.abbreviated).day()))
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
            }
            
            if isRoundTrip {
                Divider()
                    .frame(height: 60)
                
                // Return Date
                Button(action: {
                    datePickerType = .return
                    showingDatePicker = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Return")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(returnDate.formatted(.dateTime.weekday(.wide)))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(returnDate.formatted(.dateTime.month(.abbreviated).day()))
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(16)
                }
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var passengerSelectionCard: some View {
        Button(action: {
            showingPassengerView = true
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Passengers")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(passengers.totalCount) Passenger\(passengers.totalCount > 1 ? "s" : "")")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    if passengers.totalCount > 1 {
                        Text(passengers.description)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "person.2.fill")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
            }
            .padding(16)
        }
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    private var searchButton: some View {
        NavigationLink(destination: FlightsListView()) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .medium))
                
                Text("Search Flights")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: Color.blue.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(fromStation == nil || toStation == nil)
        .opacity(fromStation == nil || toStation == nil ? 0.6 : 1.0)
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
}

struct DatePickerView: View {
    @Binding var selectedDate: Date
    let title: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "Select Date",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: .date
                )
                .datePickerStyle(.graphical)
                .padding()
                
                Spacer()
                
                Button("Done") {
                    dismiss()
                }
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.blue)
                .cornerRadius(12)
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
    }
}

#Preview {
    FlightSearchView()
}