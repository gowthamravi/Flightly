import XCTest
@testable import FlightSearch

// Mock Authentication Service for testing
class MockAuthenticationService: AuthenticationServiceProtocol {
    var shouldSucceed: Bool
    var loginCalled = false

    init(shouldSucceed: Bool) {
        self.shouldSucceed = shouldSucceed
    }

    func login(email: String, password: String) async throws {
        loginCalled = true
        if shouldSucceed {
            return
        } else {
            throw AuthError.invalidCredentials
        }
    }
}

@MainActor
final class LoginViewModelTests: XCTestCase {

    func test_initialState_isCorrect() {
        let viewModel = LoginViewModel()
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isLoggingIn)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.loginSuccessful)
        XCTAssertTrue(viewModel.isLoginDisabled, "Login button should be disabled initially")
    }

    func test_isLoginDisabled_whenFieldsArePopulated() {
        let viewModel = LoginViewModel()
        viewModel.email = "test@test.com"
        viewModel.password = "password"
        XCTAssertFalse(viewModel.isLoginDisabled, "Login button should be enabled when fields are populated")
    }

    func test_isLoginDisabled_whenLoggingIn() {
        let viewModel = LoginViewModel()
        viewModel.email = "test@test.com"
        viewModel.password = "password"
        viewModel.isLoggingIn = true
        XCTAssertTrue(viewModel.isLoginDisabled, "Login button should be disabled while logging in")
    }

    func test_login_succeeds() async {
        // Given
        let mockAuthService = MockAuthenticationService(shouldSucceed: true)
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.email = "test@flightly.com"
        viewModel.password = "password123"

        // When
        await viewModel.login()

        // Then
        XCTAssertTrue(mockAuthService.loginCalled)
        XCTAssertFalse(viewModel.isLoggingIn, "isLoggingIn should be false after request completes")
        XCTAssertTrue(viewModel.loginSuccessful, "loginSuccessful should be true on success")
        XCTAssertNil(viewModel.errorMessage, "errorMessage should be nil on success")
    }

    func test_login_fails_withInvalidCredentials() async {
        // Given
        let mockAuthService = MockAuthenticationService(shouldSucceed: false)
        let viewModel = LoginViewModel(authService: mockAuthService)
        viewModel.email = "wrong@email.com"
        viewModel.password = "wrongpassword"

        // When
        await viewModel.login()

        // Then
        XCTAssertTrue(mockAuthService.loginCalled)
        XCTAssertFalse(viewModel.isLoggingIn, "isLoggingIn should be false after request completes")
        XCTAssertFalse(viewModel.loginSuccessful, "loginSuccessful should be false on failure")
        XCTAssertNotNil(viewModel.errorMessage, "errorMessage should be populated on failure")
        XCTAssertEqual(viewModel.errorMessage, AuthError.invalidCredentials.description)
    }
}
