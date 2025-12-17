import XCTest
@testable import FlightSearch // Replace with your actual project name

// MARK: - Mock AuthService

class MockAuthService: AuthServiceProtocol {
    var loginShouldSucceed: Bool = true
    var loginCallCount = 0
    var receivedEmail: String?
    var receivedPassword: String?

    func login(email: String, password: String) async throws -> User {
        loginCallCount += 1
        receivedEmail = email
        receivedPassword = password
        
        if loginShouldSucceed {
            return User(id: UUID(), email: email, name: "Mock User")
        } else {
            throw AuthError.invalidCredentials
        }
    }
}

// MARK: - ViewModel Tests

@MainActor
class LoginViewModelTests: XCTestCase {

    var viewModel: LoginViewModel!
    var mockAuthService: MockAuthService!

    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        viewModel = LoginViewModel(authService: mockAuthService)
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled initially")
    }

    func testLoginButtonDisabledWhenOnlyEmailIsFilled() {
        viewModel.email = "test@example.com"
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled when only email is filled")
    }
    
    func testLoginButtonDisabledWhenOnlyPasswordIsFilled() {
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled when only password is filled")
    }

    func testLoginButtonEnabledWhenBothFieldsAreFilled() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        XCTAssertFalse(viewModel.isLoginButtonDisabled, "Login button should be enabled when both fields are filled")
    }

    func testLoginSuccessful() async {
        // Given
        mockAuthService.loginShouldSucceed = true
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        // When
        viewModel.login()
        
        // Then
        XCTAssertTrue(viewModel.isLoading, "isLoading should be true immediately after calling login")
        
        // Await async operation completion
        await Task.yield()

        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        XCTAssertEqual(mockAuthService.receivedEmail, "test@example.com")
        XCTAssertEqual(mockAuthService.receivedPassword, "password123")
        XCTAssertFalse(viewModel.isLoading, "isLoading should be false after login completes")
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.isAuthenticated, "isAuthenticated should be true on successful login")
    }

    func testLoginFailsWithInvalidCredentials() async {
        // Given
        mockAuthService.loginShouldSucceed = false
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrongpassword"

        // When
        viewModel.login()
        
        // Then
        XCTAssertTrue(viewModel.isLoading)
        
        // Await async operation completion
        await Task.yield()

        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(viewModel.errorMessage, AuthError.invalidCredentials.localizedDescription)
    }
    
    func testLoginButtonDisabledWhileLoading() {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        // When
        viewModel.isLoading = true
        
        // Then
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled while loading")
    }
}
