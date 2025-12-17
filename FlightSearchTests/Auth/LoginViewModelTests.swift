import XCTest
import Combine
@testable import FlightSearch

// Mock Authentication Service for isolated testing of the ViewModel
class MockAuthenticationService: AuthenticationServiceProtocol {
    
    var shouldSucceed: Bool = true
    var loginCallCount = 0
    
    func login(email: String, password: String) async throws {
        loginCallCount += 1
        if shouldSucceed {
            return
        } else {
            throw AuthError.invalidCredentials
        }
    }
}

@MainActor
class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    var mockAuthService: MockAuthenticationService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        viewModel = LoginViewModel(authenticationService: mockAuthService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled initially")
    }
    
    func testLoginButtonStateChanges() {
        // Initially disabled
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
        
        // Disabled if only email is filled
        viewModel.email = "test@example.com"
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
        
        // Enabled when both are filled
        viewModel.password = "password"
        XCTAssertFalse(viewModel.isLoginButtonDisabled)
        
        // Disabled if password becomes empty again
        viewModel.password = ""
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
    }

    func testLoginSuccess() async {
        // Given
        mockAuthService.shouldSucceed = true
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        let expectation = self.expectation(description: "Wait for isAuthenticated to become true")
        viewModel.$isAuthenticated
            .dropFirst()
            .sink { isAuthenticated in
                if isAuthenticated {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.login()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testLoginFailure() async {
        // Given
        mockAuthService.shouldSucceed = false
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrong"
        
        let expectation = self.expectation(description: "Wait for errorMessage to be set")
        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // When
        viewModel.login()
        
        // Then
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, AuthError.invalidCredentials.localizedDescription)
    }
    
    func testLoadingStateDuringLogin() {
        // Given
        mockAuthService.shouldSucceed = true
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        
        // When
        viewModel.login()
        
        // Then
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true immediately after login starts")
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled while loading")
    }
}
