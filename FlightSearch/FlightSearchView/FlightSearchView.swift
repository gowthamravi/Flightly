import SwiftUI

struct FlightSearchView: View {
    @State private var fromStation: Station?
    @State private var toStation: Station?
    @State private var departureDate = Date()
    @State private var returnDate = Date().addingTimeInterval(86400)
    @State private var passengers = Passengers()
    @State private var isOneWay = false
    @State private var showingStationPicker = false
    @State private var isSelectingFromStation = true
    @State private var showingPassengerPicker = false
    @State private var showingDatePicker = false
    @State private var isSelectingDepartureDate = true
    
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
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStationPicker) {
            StationListView(
                selectedStation: isSelectingFromStation ? $fromStation : $toStation,
                isPresented: $showingStationPicker
            )
        }
        .sheet(isPresented: $showingPassengerPicker) {
            PassengerView(passengers: $passengers, isPresented: $showingPassengerPicker)
        }
    }
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Book Your Flight")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Find the best deals for your journey")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 20)
    }
    
    private var tripTypeSelector: some View {
        HStack(spacing: 0) {
            tripTypeButton(title: "Round Trip", isSelected: !isOneWay) {
                isOneWay = false
            }
            
            tripTypeButton(title: "One Way", isSelected: isOneWay) {
                isOneWay = true
            }
        }
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 4)
    }
    
    private func tripTypeButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isSelected ? Color.blue : Color.clear)
                )
        }
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
    
    private var stationSelectionCard: some View {
        VStack(spacing: 0) {
            // From Station
            stationRow(
                title: "From",
                station: fromStation,
                placeholder: "Select departure city"
            ) {
                isSelectingFromStation = true
                showingStationPicker = true
            }
            
            Divider()
                .padding(.horizontal, 16)
            
            // Swap Button
            HStack {
                Spacer()
                Button(action: swapStations) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.blue)
                        .frame(width: 40, height: 40)
                        .background(Color(.systemGray6))
                        .clipShape(Circle())
                }
                .offset(y: -8)
                Spacer()
            }
            .zIndex(1)
            
            // To Station
            stationRow(
                title: "To",
                station: toStation,
                placeholder: "Select destination city"
            ) {
                isSelectingFromStation = false
                showingStationPicker = true
            }
            .offset(y: -16)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private func stationRow(title: String, station: Station?, placeholder: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    if let station = station {
                        Text(station.name)
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(station.code)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    } else {
                        Text(placeholder)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var dateSelectionCard: some View {
        VStack(spacing: 0) {
            // Departure Date
            dateRow(
                title: "Departure",
                date: departureDate
            ) {
                isSelectingDepartureDate = true
                showingDatePicker = true
            }
            
            if !isOneWay {
                Divider()
                    .padding(.horizontal, 16)
                
                // Return Date
                dateRow(
                    title: "Return",
                    date: returnDate
                ) {
                    isSelectingDepartureDate = false
                    showingDatePicker = true
                }
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .sheet(isPresented: $showingDatePicker) {
            DateView(
                selectedDate: isSelectingDepartureDate ? $departureDate : $returnDate,
                isPresented: $showingDatePicker,
                title: isSelectingDepartureDate ? "Select Departure Date" : "Select Return Date"
            )
        }
    }
    
    private func dateRow(title: String, date: Date, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text(date.formatted(date: .abbreviated, time: .omitted))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(date.formatted(.dateTime.weekday(.wide)))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var passengerSelectionCard: some View {
        Button(action: {
            showingPassengerPicker = true
        }) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Passengers")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                    
                    Text("\(passengers.totalCount) Passenger\(passengers.totalCount == 1 ? "" : "s")")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text(passengers.description)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "person.2")
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
        }
        .buttonStyle(PlainButtonStyle())
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
    }
    
    private var searchButton: some View {
        Button(action: searchFlights) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 18, weight: .semibold))
                
                Text("Search Flights")
                    .font(.system(size: 18, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(!isSearchEnabled)
        .opacity(isSearchEnabled ? 1.0 : 0.6)
        .padding(.top, 8)
    }
    
    private var isSearchEnabled: Bool {
        fromStation != nil && toStation != nil
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
    
    private func searchFlights() {
        // Implement flight search logic
        print("Searching flights from \(fromStation?.name ?? "") to \(toStation?.name ?? "")")
    }
}