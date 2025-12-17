import SwiftUI

struct RecentSearchesView: View {
    let recentSearches: [FlightSearch]
    let onSearchSelected: (FlightSearch) -> Void
    let onClearAll: () -> Void

    var body: some View {
        if !recentSearches.isEmpty {
            Section {
                ForEach(recentSearches) { search in
                    Button(action: { onSearchSelected(search) }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("\(search.origin.code) to \(search.destination.code)")
                                    .font(.headline)
                                Text(search.journeyDate, style: .date)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 8)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                HStack {
                    Text("Recent Searches")
                    Spacer()
                    Button("Clear All", action: onClearAll)
                        .font(.caption)
                }
            }
        }
    }
}

struct RecentSearchesView_Previews: PreviewProvider {
    static let sampleSearches: [FlightSearch] = [
        .init(id: UUID(), origin: .init(code: "SFO", name: "San Francisco"), destination: .init(code: "LAX", name: "Los Angeles"), journeyDate: .now, passengers: .init(adults: 1, children: 0, infants: 0)),
        .init(id: UUID(), origin: .init(code: "JFK", name: "New York"), destination: .init(code: "ORD", name: "Chicago"), journeyDate: .now.addingTimeInterval(86400 * 2), passengers: .init(adults: 2, children: 1, infants: 0))
    ]
    
    static var previews: some View {
        Form {
            RecentSearchesView(
                recentSearches: sampleSearches,
                onSearchSelected: { _ in print("Search selected") },
                onClearAll: { print("Clear all") }
            )
        }
    }
}
