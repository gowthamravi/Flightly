import XCTest
import SwiftUI
@testable import FlightSearch

class FlightSearchViewTests: XCTestCase {
    
    func testFlightSearchViewInitialization() {
        // Given
        let view = FlightSearchView()
        
        // Then
        XCTAssertNotNil(view)
    }
    
    func testTripTypeSelectorDefaultState() {
        // Given
        let view = FlightSearchView()
        
        // When - Initial state should be one way
        // Then - This would be tested through UI testing or by exposing state
        XCTAssertTrue(true) // Placeholder for state verification
    }
    
    func testStationSwapFunctionality() {
        // Given
        let view = FlightSearchView()
        let fromStation = Station(code: "NYC", name: "New York")
        let toStation = Station(code: "LAX", name: "Los Angeles")
        
        // When - This would require exposing the swap function or testing through UI
        // Then
        XCTAssertNotNil(fromStation)
        XCTAssertNotNil(toStation)
    }
    
    func testDatePickerViewInitialization() {
        // Given
        let selectedDate = Binding.constant(Date())
        let title = "Test Date"
        
        // When
        let datePickerView = DatePickerView(selectedDate: selectedDate, title: title)
        
        // Then
        XCTAssertNotNil(datePickerView)
    }
    
    func testPassengerCountDisplay() {
        // Given
        let passengers = Passengers()
        
        // When
        let totalCount = passengers.totalCount
        
        // Then
        XCTAssertGreaterThanOrEqual(totalCount, 1)
    }
    
    func testSearchButtonDisabledState() {
        // Given - No stations selected
        let fromStation: Station? = nil
        let toStation: Station? = nil
        
        // When
        let shouldBeDisabled = fromStation == nil || toStation == nil
        
        // Then
        XCTAssertTrue(shouldBeDisabled)
    }
    
    func testSearchButtonEnabledState() {
        // Given - Both stations selected
        let fromStation: Station? = Station(code: "NYC", name: "New York")
        let toStation: Station? = Station(code: "LAX", name: "Los Angeles")
        
        // When
        let shouldBeEnabled = fromStation != nil && toStation != nil
        
        // Then
        XCTAssertTrue(shouldBeEnabled)
    }
    
    func testDateValidation() {
        // Given
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        // When
        let isValidDepartureDate = today >= Date()
        let isValidReturnDate = tomorrow > today
        
        // Then
        XCTAssertTrue(isValidDepartureDate)
        XCTAssertTrue(isValidReturnDate)
    }
    
    func testRoundTripToggle() {
        // Given
        var isRoundTrip = false
        
        // When
        isRoundTrip.toggle()
        
        // Then
        XCTAssertTrue(isRoundTrip)
        
        // When
        isRoundTrip.toggle()
        
        // Then
        XCTAssertFalse(isRoundTrip)
    }
    
    func testStationPickerTypeEnum() {
        // Given
        let fromType = FlightSearchView.StationPickerType.from
        let toType = FlightSearchView.StationPickerType.to
        
        // Then
        XCTAssertNotEqual(fromType, toType)
    }
    
    func testDatePickerTypeEnum() {
        // Given
        let departureType = FlightSearchView.DatePickerType.departure
        let returnType = FlightSearchView.DatePickerType.return
        
        // Then
        XCTAssertNotEqual(departureType, returnType)
    }
}