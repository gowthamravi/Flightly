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
    @Environment(\.dismiss) private var dismiss
    
    enum StationPickerType {
        case from, to
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // Header
                    headerView
                    
                    // Main Content
                    VStack(spacing: 24) {
                        // Trip Type Selector
                        tripTypeSelector
                        
                        // Flight Route Card
                        flightRouteCard
                        
                        // Date Selection Card
                        dateSelectionCard
                        
                        // Passenger Selection Card
                        passengerSelectionCard
                        
                        // Search Button
                        searchButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                }
            }
            .background(Color(red: 0.97, green: 0.98, blue: 1.0))
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStationPicker) {
            StationListView(selectedStation: stationPickerType == .from ? $fromStation : $toStation)
        }
        .sheet(isPresented: $showingPassengerView) {
            PassengerView(isPresented: $showingPassengerView, passengers: $passengers, passengerList: passengers)
        }
    }
    
    private var headerView: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.2, green: 0.4, blue: 0.8),
                    Color(red: 0.1, green: 0.3, blue: 0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 120)
            
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    Text("Search Flights")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    // Placeholder for balance
                    Color.clear
                        .frame(width: 24, height: 24)
                }
                .padding(.horizontal, 16)
                .padding(.top, 50)
                
                Spacer()
            }
        }
    }
    
    private var tripTypeSelector: some View {
        HStack(spacing: 0) {
            Button(action: { isRoundTrip = false }) {
                Text("One Way")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isRoundTrip ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        isRoundTrip ? Color.clear : Color(red: 0.2, green: 0.4, blue: 0.8)
                    )
            }
            
            Button(action: { isRoundTrip = true }) {
                Text("Round Trip")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isRoundTrip ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .background(
                        isRoundTrip ? Color(red: 0.2, green: 0.4, blue: 0.8) : Color.clear
                    )
            }
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private var flightRouteCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Flight Route")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // From Station
                Button(action: {
                    stationPickerType = .from
                    showingStationPicker = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("From")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text(fromStation?.code ?? "Select")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Text(fromStation?.name ?? "Departure city")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
                
                // Swap Button
                Button(action: swapStations) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.system(size: 16))
                        .foregroundColor(Color(red: 0.2, green: 0.4, blue: 0.8))
                        .frame(width: 32, height: 32)
                        .background(Color.white)
                        .cornerRadius(16)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                }
                
                // To Station
                Button(action: {
                    stationPickerType = .to
                    showingStationPicker = true
                }) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("To")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        HStack {
                            Text(toStation?.code ?? "Select")
                                .font(.system(size: 16, weight: .bold))
                                .foregroundColor(.black)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.system(size: 12))
                                .foregroundColor(.gray)
                        }
                        
                        Text(toStation?.name ?? "Destination city")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var dateSelectionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Travel Dates")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            HStack(spacing: 12) {
                // Departure Date
                DateView(
                    title: "Departure",
                    date: $departureDate,
                    isSelected: true
                )
                
                if isRoundTrip {
                    // Return Date
                    DateView(
                        title: "Return",
                        date: $returnDate,
                        isSelected: true
                    )
                }
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var passengerSelectionCard: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Passengers")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                Spacer()
            }
            
            Button(action: {
                showingPassengerView = true
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(passengers.totalCount) Passenger\(passengers.totalCount > 1 ? "s" : "")")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.black)
                        
                        Text(passengers.description)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
    
    private var searchButton: some View {
        NavigationLink(destination: FlightsListView(
            fromStation: fromStation,
            toStation: toStation,
            departureDate: departureDate,
            returnDate: isRoundTrip ? returnDate : nil,
            passengers: passengers
        )) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 16, weight: .medium))
                
                Text("Search Flights")
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(red: 0.2, green: 0.4, blue: 0.8),
                        Color(red: 0.1, green: 0.3, blue: 0.7)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
            .shadow(color: Color(red: 0.2, green: 0.4, blue: 0.8).opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .disabled(fromStation == nil || toStation == nil)
        .opacity(fromStation == nil || toStation == nil ? 0.6 : 1.0)
        .padding(.top, 8)
    }
    
    private func swapStations() {
        let temp = fromStation
        fromStation = toStation
        toStation = temp
    }
}

struct FlightSearchView_Previews: PreviewProvider {
    static var previews: some View {
        FlightSearchView()
    }
}