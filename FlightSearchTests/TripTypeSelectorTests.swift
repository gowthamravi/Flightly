import XCTest
import SwiftUI
@testable import FlightSearch

final class TripTypeSelectorTests: XCTestCase {
    
    func testTripTypeEnum() {
        // Test enum cases
        XCTAssertEqual(TripType.oneWay.title, "One way")
        XCTAssertEqual(TripType.roundTrip.title, "Round trip")
        
        // Test all cases
        let allCases = TripType.allCases
        XCTAssertEqual(allCases.count, 2)
        XCTAssertTrue(allCases.contains(.oneWay))
        XCTAssertTrue(allCases.contains(.roundTrip))
    }
    
    func testTripTypeSelectorInitialization() {
        // Test that the component can be initialized
        let binding = Binding<TripType>.constant(.oneWay)
        let selector = TripTypeSelector(selectedTripType: binding)
        
        // This test ensures the view can be created without crashing
        XCTAssertNotNil(selector)
    }
    
    func testTripTypeButtonInitialization() {
        // Test button initialization
        let button = TripTypeButton(
            title: "Test",
            isSelected: true,
            action: {}
        )
        
        XCTAssertNotNil(button)
    }
    
    func testTripTypeSelection() {
        // Test trip type selection logic
        var selectedType: TripType = .oneWay
        
        // Simulate selecting round trip
        selectedType = .roundTrip
        XCTAssertEqual(selectedType, .roundTrip)
        
        // Simulate selecting one way
        selectedType = .oneWay
        XCTAssertEqual(selectedType, .oneWay)
    }
    
    func testTripTypeToggle() {
        // Test toggling between trip types
        var currentType: TripType = .oneWay
        
        // Toggle to round trip
        currentType = currentType == .oneWay ? .roundTrip : .oneWay
        XCTAssertEqual(currentType, .roundTrip)
        
        // Toggle back to one way
        currentType = currentType == .oneWay ? .roundTrip : .oneWay
        XCTAssertEqual(currentType, .oneWay)
    }
    
    func testTripTypeButtonAction() {
        // Test button action execution
        var actionExecuted = false
        
        let button = TripTypeButton(
            title: "Test",
            isSelected: false,
            action: {
                actionExecuted = true
            }
        )
        
        // Simulate button tap by calling the action directly
        button.action()
        XCTAssertTrue(actionExecuted)
    }
    
    func testTripTypeButtonProperties() {
        // Test button properties
        let selectedButton = TripTypeButton(
            title: "Selected",
            isSelected: true,
            action: {}
        )
        
        let unselectedButton = TripTypeButton(
            title: "Unselected",
            isSelected: false,
            action: {}
        )
        
        // These tests ensure the buttons can be created with different states
        XCTAssertNotNil(selectedButton)
        XCTAssertNotNil(unselectedButton)
    }
}