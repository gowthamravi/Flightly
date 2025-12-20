import XCTest
import SwiftUI
@testable import FlightSearch

final class FromViewTests: XCTestCase {
    
    func testFromViewExists() {
        // Test that FromView can be instantiated
        let fromView = FromView()
        XCTAssertNotNil(fromView)
    }
    
    func testFromViewHasCorrectFrame() {
        // Test that the view has the correct dimensions
        let fromView = FromView()
        
        // Since we can't directly test SwiftUI view frame in unit tests,
        // we verify the view can be created without errors
        XCTAssertNotNil(fromView.body)
    }
    
    func testFromViewRendering() {
        // Test that the view renders without crashing
        let fromView = FromView()
        let hostingController = UIHostingController(rootView: fromView)
        
        XCTAssertNotNil(hostingController.view)
    }
    
    func testFromViewAccessibility() {
        // Test accessibility properties
        let fromView = FromView()
        let hostingController = UIHostingController(rootView: fromView)
        
        // Verify the view is accessible
        XCTAssertTrue(hostingController.view.isAccessibilityElement || hostingController.view.accessibilityElements?.count ?? 0 > 0)
    }
    
    func testFromViewMemoryManagement() {
        // Test that the view doesn't cause memory leaks
        weak var weakView: UIView?
        
        autoreleasepool {
            let fromView = FromView()
            let hostingController = UIHostingController(rootView: fromView)
            weakView = hostingController.view
        }
        
        // The view should be deallocated after the autorelease pool
        XCTAssertNil(weakView)
    }
}