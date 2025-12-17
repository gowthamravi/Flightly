import Foundation
import Combine

class FlightSearchViewModel: ObservableObject {
    @Published var origin: Station?
    @Published var destination: Station?
    @Published var journeyDate: Date = Date()
    @Published var passengers: Passengers = .init(adults: 1, children: 0, infants: 0)
    
    @Published var recentSearches: [FlightSearch] = []
    
    private let recentSearchesStore: RecentSearchesStoring
    
    init(recentSearchesStore: RecentSearchesStoring = RecentSearchesStore()) {
        self.recentSearchesStore = recentSearchesStore
        loadRecentSearches()
    }
    
    func loadRecentSearches() {
        self.recentSearches = recentSearchesStore.fetchRecentSearches()
    }
    
    func performSearch() {
        guard let origin = origin, let destination = destination else {
            return
        }
        
        let newSearch = FlightSearch(
            id: UUID(),
            origin: origin,
            destination: destination,
            journeyDate: journeyDate,
            passengers: passengers
        )
        
        recentSearchesStore.saveSearch(newSearch)
        loadRecentSearches()
    }
    
    func selectRecentSearch(_ search: FlightSearch) {
        self.origin = search.origin
        self.destination = search.destination
        self.journeyDate = search.journeyDate
        self.passengers = search.passengers
    }
    
    func clearRecentSearches() {
        recentSearchesStore.clearAll()
        loadRecentSearches()
    }
    
    func swapOriginDestination() {
        let temp = origin
        origin = destination
        destination = temp
    }
}
