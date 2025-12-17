import XCTest
import Combine
@testable import FlightSearch

class MockRecentSearchesStore: RecentSearchesStoring {
    var searches: [FlightSearch] = []
    var saveSearchCalled = false
    var clearAllCalled = false
    var lastSavedSearch: FlightSearch?

    func fetchRecentSearches() -> [FlightSearch] {
        return searches
    }

    func saveSearch(_ search: FlightSearch) {
        saveSearchCalled = true
        lastSavedSearch = search
        searches.removeAll { $0.origin.code == search.origin.code && $0.destination.code == search.destination.code }
        searches.insert(search, at: 0)
    }
    
    func clearAll() {
        clearAllCalled = true
        searches.removeAll()
    }
}

class FlightSearchViewModelTests: XCTestCase {

    var viewModel: FlightSearchViewModel!
    var mockStore: MockRecentSearchesStore!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockStore = MockRecentSearchesStore()
        viewModel = FlightSearchViewModel(recentSearchesStore: mockStore)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockStore = nil
        cancellables = nil
        super.tearDown()
    }

    func testInit_LoadsRecentSearches() {
        let search = createSampleSearch(originCode: "SFO", destCode: "LAX")
        mockStore.searches = [search]
        
        viewModel = FlightSearchViewModel(recentSearchesStore: mockStore)
        
        XCTAssertEqual(viewModel.recentSearches.count, 1)
        XCTAssertEqual(viewModel.recentSearches.first?.id, search.id)
    }

    func testPerformSearch_SavesSearchAndRefreshesList() {
        viewModel.origin = Station(code: "JFK", name: "New York")
        viewModel.destination = Station(code: "LAX", name: "Los Angeles")
        
        viewModel.performSearch()
        
        XCTAssertTrue(mockStore.saveSearchCalled)
        XCTAssertEqual(mockStore.lastSavedSearch?.origin.code, "JFK")
        XCTAssertEqual(viewModel.recentSearches.count, 1)
        XCTAssertEqual(viewModel.recentSearches.first?.origin.code, "JFK")
    }
    
    func testPerformSearch_WhenOriginOrDestinationIsNil_DoesNotSave() {
        viewModel.origin = nil
        viewModel.destination = Station(code: "LAX", name: "Los Angeles")
        viewModel.performSearch()
        XCTAssertFalse(mockStore.saveSearchCalled)
    }

    func testSelectRecentSearch_UpdatesViewModelProperties() {
        let search = createSampleSearch(originCode: "DEN", destCode: "MIA")
        viewModel.selectRecentSearch(search)
        
        XCTAssertEqual(viewModel.origin?.code, "DEN")
        XCTAssertEqual(viewModel.destination?.code, "MIA")
        XCTAssertEqual(viewModel.journeyDate, search.journeyDate)
    }
    
    func testClearRecentSearches_ClearsStoreAndUpdatesList() {
        mockStore.searches = [createSampleSearch(originCode: "SFO", destCode: "LAX")]
        viewModel.loadRecentSearches()
        
        viewModel.clearRecentSearches()
        
        XCTAssertTrue(mockStore.clearAllCalled)
        XCTAssertTrue(viewModel.recentSearches.isEmpty)
    }
    
    func testSwapOriginDestination_SwapsStations() {
        let origin = Station(code: "SFO", name: "San Francisco")
        let destination = Station(code: "LAX", name: "Los Angeles")
        viewModel.origin = origin
        viewModel.destination = destination
        
        viewModel.swapOriginDestination()
        
        XCTAssertEqual(viewModel.origin?.code, "LAX")
        XCTAssertEqual(viewModel.destination?.code, "SFO")
    }

    private func createSampleSearch(originCode: String, destCode: String) -> FlightSearch {
        return FlightSearch(
            id: UUID(),
            origin: Station(code: originCode, name: "Origin"),
            destination: Station(code: destCode, name: "Destination"),
            journeyDate: Date(),
            passengers: Passengers(adults: 1, children: 0, infants: 0)
        )
    }
}
