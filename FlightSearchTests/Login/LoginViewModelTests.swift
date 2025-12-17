import XCTest
@testable import FlightSearch // Replace with your actual project name

// Mock Authentication Service for testing the ViewModel in isolation.
class MockAuthenticationService: AuthenticationServiceProtocol {
    var loginResult: Result<User, AuthError>!

    func login(email: String, password: String) async -> Result<User, AuthError> {
        // Simulate a delay to allow isLoading state to be tested
        try? await Task.sleep(nanoseconds: 100_000_000)
        return loginResult
    }
}

@MainActor
class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    var mockAuthService: MockAuthenticationService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthenticationService()
        viewModel = LoginViewModel(authenticationService: mockAuthService)
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testLogin_WithEmptyCredentials_ShowsError() {
        viewModel.email = ""
        viewModel.password = ""

        viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Email and password cannot be empty.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testLogin_WithInvalidEmailFormat_ShowsError() {
        viewModel.email = "invalid-email"
        viewModel.password = "password123"

        viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email address.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
    }

    func testLogin_Successful() async {
        let user = User(id: UUID(), email: "test@example.com", name: "Test User")
        mockAuthService.loginResult = .success(user)
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        viewModel.login()
        
        // Check loading state immediately
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        
        // Wait for the async login task to complete
        await Task.yield()
        try? await Task.sleep(nanoseconds: 200_000_000) // Wait for mock service delay

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testLogin_Failed_InvalidCredentials() async {
        mockAuthService.loginResult = .failure(.invalidCredentials)
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrongpassword"

        viewModel.login()
        
        XCTAssertTrue(viewModel.isLoading)
        
        await Task.yield()
        try? await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.errorMessage, "Invalid email or password. Please try again.")
    }
}
