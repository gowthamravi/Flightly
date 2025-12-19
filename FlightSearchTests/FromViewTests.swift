import XCTest
import SwiftUI
@testable import FlightSearch

final class FromViewTests: XCTestCase {
    
    func testFromViewInitialization() {
        // Given
        let fromView = FromView()
        
        // Then
        XCTAssertNotNil(fromView)
    }
    
    func testDefaultValues() {
        // Given
        let fromView = FromView()
        
        // When - Create a hosting controller to access state
        let hostingController = UIHostingController(rootView: fromView)
        
        // Then
        XCTAssertNotNil(hostingController.rootView)
    }
    
    func testFromViewRendering() {
        // Given
        let fromView = FromView()
        
        // When
        let hostingController = UIHostingController(rootView: fromView)
        
        // Then
        XCTAssertNotNil(hostingController.view)
        XCTAssertEqual(hostingController.view.backgroundColor, UIColor.clear)
    }
    
    func testFromViewAccessibility() {
        // Given
        let fromView = FromView()
        let hostingController = UIHostingController(rootView: fromView)
        
        // When
        let view = hostingController.view
        
        // Then
        XCTAssertNotNil(view)
        XCTAssertTrue(view?.isAccessibilityElement == false) // Container view
    }
    
    func testFromViewLayout() {
        // Given
        let fromView = FromView()
        let hostingController = UIHostingController(rootView: fromView)
        
        // When
        hostingController.loadViewIfNeeded()
        
        // Then
        XCTAssertNotNil(hostingController.view)
        XCTAssertGreaterThan(hostingController.view.frame.width, 0)
    }
}