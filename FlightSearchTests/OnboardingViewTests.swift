import XCTest
import SwiftUI
@testable import FlightSearch

final class OnboardingViewTests: XCTestCase {
    
    func testOnboardingDataInitialization() {
        // Given
        let image = "TestImage"
        let title = "Test Title"
        let subtitle = "Test Subtitle"
        let description = "Test Description"
        
        // When
        let onboardingData = OnboardingData(
            image: image,
            title: title,
            subtitle: subtitle,
            description: description
        )
        
        // Then
        XCTAssertEqual(onboardingData.image, image)
        XCTAssertEqual(onboardingData.title, title)
        XCTAssertEqual(onboardingData.subtitle, subtitle)
        XCTAssertEqual(onboardingData.description, description)
    }
    
    func testOnboardingViewInitialState() {
        // Given & When
        let onboardingView = OnboardingView()
        
        // Then
        // Test that the view can be initialized without crashing
        XCTAssertNotNil(onboardingView)
    }
    
    func testOnboardingDataCount() {
        // Given
        let onboardingView = OnboardingView()
        
        // When
        let dataCount = onboardingView.onboardingData.count
        
        // Then
        XCTAssertEqual(dataCount, 3, "Onboarding should have exactly 3 pages")
    }
    
    func testOnboardingDataContent() {
        // Given
        let onboardingView = OnboardingView()
        let data = onboardingView.onboardingData
        
        // Then
        XCTAssertEqual(data[0].image, "Cover")
        XCTAssertEqual(data[0].title, "Welcome to FlightSearch")
        XCTAssertTrue(data[0].subtitle.contains("best flights"))
        
        XCTAssertEqual(data[1].image, "OnBoarding")
        XCTAssertEqual(data[1].title, "Easy Booking")
        XCTAssertTrue(data[1].subtitle.contains("few taps"))
        
        XCTAssertEqual(data[2].image, "BoardingPass")
        XCTAssertEqual(data[2].title, "Digital Boarding Pass")
        XCTAssertTrue(data[2].subtitle.contains("instantly"))
    }
    
    func testRoundedCornerShape() {
        // Given
        let shape = RoundedCorner(radius: 10, corners: [.topLeft, .topRight])
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        
        // When
        let path = shape.path(in: rect)
        
        // Then
        XCTAssertNotNil(path)
        XCTAssertFalse(path.isEmpty)
    }
    
    func testRoundedCornerDefaultValues() {
        // Given & When
        let shape = RoundedCorner()
        
        // Then
        XCTAssertEqual(shape.radius, .infinity)
        XCTAssertEqual(shape.corners, .allCorners)
    }
}