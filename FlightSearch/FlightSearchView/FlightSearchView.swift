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
        case departure, returnDate
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerView
                    
                    // Search Form
                    searchFormView
                    
                    // Search Button
                    searchButtonView
                    
                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.1), Color.white]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingStationPicker) {
            StationListView(selectedStation: stationPickerType == .from ? $fromStation : $toStation)
        }
        .sheet(isPresented: $showingPassengerPicker) {
            PassengerView(passengers: $passengers, isPresented: $showingPassengerPicker, passengerList: $passengers)
        }
        .sheet(isPresented: $showingDatePicker) {
            SelectDateView(
                selectedDate: datePickerType == .departure ? $departureDate : $returnDate,
                isPresented: $showingDatePicker
            )
            .navigationBarBackButtonHidden(true)
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Hello Gowtham!")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Where would you like to go?")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "bell")
                        .font(.title2)
                        .foregroundColor(.primary)
                }
            }
            
            // Trip Type Selector
            tripTypeSelectorView
        }
    }
    
    private var tripTypeSelectorView: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRoundTrip = false
                }
            }) {
                Text("One way")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isRoundTrip ? .secondary : .white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isRoundTrip ? Color.clear : Color.blue)
                    )
            }
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isRoundTrip = true
                }
            }) {
                Text("Round trip")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isRoundTrip ? .white : .secondary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 25)
                            .fill(isRoundTrip ? Color.blue : Color.clear)
                    )
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        )
    }
    
    private var searchFormView: some View {
        VStack(spacing: 16) {
            // Station Selection
            stationSelectionView
            
            // Date Selection
            dateSelectionView
            
            // Passenger Selection
            passengerSelectionView
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white)
                .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 2)
        )
    }
    
    private var stationSelectionView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("From")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        stationPickerType = .from
                        showingStationPicker = true
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(fromStation?.code ?? "Select")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(fromStation?.name ?? "Departure city")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            
                            Spacer()
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Spacer()
                
                Button(action: {
                    let temp = fromStation
                    fromStation = toStation
                    toStation = temp
                }) {
                    Image(systemName: "arrow.left.arrow.right")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(8)
                        .background(
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                        )
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    Text("To")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        stationPickerType = .to
                        showingStationPicker = true
                    }) {
                        HStack {
                            Spacer()
                            
                            VStack(alignment: .trailing, spacing: 2) {
                                Text(toStation?.code ?? "Select")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Text(toStation?.name ?? "Destination city")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            
            Divider()
        }
    }
    
    private var dateSelectionView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Departure")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Button(action: {
                    datePickerType = .departure
                    showingDatePicker = true
                }) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(departureDate.formatted(.dateTime.day().month(.abbreviated)))
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(departureDate.formatted(.dateTime.weekday(.wide)))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
                }
            }
            
            if isRoundTrip {
                Divider()
                    .frame(height: 40)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Return")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        datePickerType = .returnDate
                        showingDatePicker = true
                    }) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(returnDate.formatted(.dateTime.day().month(.abbreviated)))
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Text(returnDate.formatted(.dateTime.weekday(.wide)))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    private var passengerSelectionView: some View {
        VStack(spacing: 8) {
            Divider()
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Passengers")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Button(action: {
                        showingPassengerPicker = true
                    }) {
                        HStack {
                            Text("\(passengers.totalCount) Passenger\(passengers.totalCount > 1 ? "s" : "")")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    private var searchButtonView: some View {
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
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
            )
        }
        .disabled(fromStation == nil || toStation == nil)
        .opacity(fromStation == nil || toStation == nil ? 0.6 : 1.0)
    }
}

#Preview {
    FlightSearchView()
}