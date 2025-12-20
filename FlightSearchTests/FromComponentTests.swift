import XCTest
import SwiftUI
@testable import FlightSearch

final class FromComponentTests: XCTestCase {
    
    func testFromComponentInitialization() {
        // Given
        let fromText = "From"
        let locationText = "Mumbai"
        
        // When
        let component = FromComponent(fromText: fromText, locationText: locationText)
        
        // Then
        XCTAssertEqual(component.fromText, fromText)
        XCTAssertEqual(component.locationText, locationText)
    }
    
    func testFromComponentDefaultValues() {
        // When
        let component = FromComponent()
        
        // Then
        XCTAssertEqual(component.fromText, "From")
        XCTAssertEqual(component.locationText, "Mumbai")
    }
    
    func testFromComponentCustomValues() {
        // Given
        let customFromText = "Departure"
        let customLocationText = "Delhi"
        
        // When
        let component = FromComponent(fromText: customFromText, locationText: customLocationText)
        
        // Then
        XCTAssertEqual(component.fromText, customFromText)
        XCTAssertEqual(component.locationText, customLocationText)
    }
    
    func testFromComponentViewRendering() {
        // Given
        let component = FromComponent()
        
        // When
        let view = component.body
        
        // Then
        XCTAssertNotNil(view)
    }
}