import XCTest
@testable import FlightSearch

// These models are defined here for test compilation purposes.
// In the actual project, they are imported from the main target.
struct Station: Codable, Hashable, Equatable {
    let code: String
    let name: String
}

struct Passengers: Codable, Hashable, Equatable {
    let adults: Int
    let children: Int
    let infants: Int
}

struct FlightSearch: Codable, Hashable, Identifiable, Equatable {
    let id: UUID
    let origin: Station
    let destination: Station
    let journeyDate: Date
    let passengers: Passengers
    
    static func == (lhs: FlightSearch, rhs: FlightSearch) -> Bool {
        return lhs.id == rhs.id
    }
}

class RecentSearchesStoreTests: XCTestCase {

    var userDefaults: UserDefaults!
    var store: RecentSearchesStore!
    let suiteName = "TestHost"

    override func setUp() {
        super.setUp()
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        store = RecentSearchesStore(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        store = nil
        super.tearDown()
    }

    func testFetchRecentSearches_WhenEmpty_ReturnsEmptyArray() {
        let searches = store.fetchRecentSearches()
        XCTAssertTrue(searches.isEmpty, "Should return an empty array when no searches are saved.")
    }

    func testSaveSearch_SavesOneSearch() {
        let search = createSampleSearch(originCode: "SFO", destCode: "LAX")
        store.saveSearch(search)
        
        let fetchedSearches = store.fetchRecentSearches()
        XCTAssertEqual(fetchedSearches.count, 1)
        XCTAssertEqual(fetchedSearches.first?.id, search.id)
    }

    func testSaveSearch_AddsNewSearchToTheTop() {
        let firstSearch = createSampleSearch(originCode: "SFO", destCode: "LAX")
        let secondSearch = createSampleSearch(originCode: "JFK", destCode: "ORD")
        
        store.saveSearch(firstSearch)
        store.saveSearch(secondSearch)
        
        let fetchedSearches = store.fetchRecentSearches()
        XCTAssertEqual(fetchedSearches.count, 2)
        XCTAssertEqual(fetchedSearches.first?.id, secondSearch.id, "The most recent search should be first.")
    }

    func testSaveSearch_DoesNotExceedMaxCount() {
        for i in 0..<10 {
            let search = createSampleSearch(originCode: "A\(i)", destCode: "B\(i)")
            store.saveSearch(search)
        }
        
        let fetchedSearches = store.fetchRecentSearches()
        XCTAssertEqual(fetchedSearches.count, 5, "The number of searches should be limited to the max count.")
        XCTAssertEqual(fetchedSearches.first?.origin.code, "A9")
    }
    
    func testSaveSearch_MovesExistingSearchToTop() {
        let sfoLax = createSampleSearch(originCode: "SFO", destCode: "LAX")
        let jfkOrd = createSampleSearch(originCode: "JFK", destCode: "ORD")
        store.saveSearch(sfoLax)
        store.saveSearch(jfkOrd)
        
        let updatedSfoLax = createSampleSearch(originCode: "SFO", destCode: "LAX", date: Date().addingTimeInterval(1000))
        store.saveSearch(updatedSfoLax)
        
        let fetchedSearches = store.fetchRecentSearches()
        XCTAssertEqual(fetchedSearches.count, 2)
        XCTAssertEqual(fetchedSearches.first?.origin.code, "SFO")
    }
    
    func testClearAll_RemovesAllSearches() {
        store.saveSearch(createSampleSearch(originCode: "SFO", destCode: "LAX"))
        store.clearAll()
        let fetchedSearches = store.fetchRecentSearches()
        XCTAssertTrue(fetchedSearches.isEmpty, "All searches should be cleared.")
    }

    private func createSampleSearch(originCode: String, destCode: String, date: Date = Date()) -> FlightSearch {
        return FlightSearch(
            id: UUID(),
            origin: Station(code: originCode, name: "Origin"),
            destination: Station(code: destCode, name: "Destination"),
            journeyDate: date,
            passengers: Passengers(adults: 1, children: 0, infants: 0)
        )
    }
}
