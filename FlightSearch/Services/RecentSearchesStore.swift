import Foundation

protocol RecentSearchesStoring {
    func fetchRecentSearches() -> [FlightSearch]
    func saveSearch(_ search: FlightSearch)
    func clearAll()
}

class RecentSearchesStore: RecentSearchesStoring {
    private let userDefaults: UserDefaults
    private let key = "recent_flight_searches"
    private let maxCount = 5

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func fetchRecentSearches() -> [FlightSearch] {
        guard let data = userDefaults.data(forKey: key) else {
            return []
        }
        do {
            let searches = try JSONDecoder().decode([FlightSearch].self, from: data)
            return searches
        } catch {
            print("Failed to decode recent searches: \(error)")
            return []
        }
    }

    func saveSearch(_ search: FlightSearch) {
        var currentSearches = fetchRecentSearches()
        
        currentSearches.removeAll { $0.origin.code == search.origin.code && $0.destination.code == search.destination.code }
        
        currentSearches.insert(search, at: 0)
        
        if currentSearches.count > maxCount {
            currentSearches = Array(currentSearches.prefix(maxCount))
        }
        
        do {
            let data = try JSONEncoder().encode(currentSearches)
            userDefaults.set(data, forKey: key)
        } catch {
            print("Failed to encode recent searches: \(error)")
        }
    }
    
    func clearAll() {
        userDefaults.removeObject(forKey: key)
    }
}
