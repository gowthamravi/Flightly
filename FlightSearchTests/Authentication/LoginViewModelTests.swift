import XCTest
import Combine
@testable import FlightSearch

// Mock Authentication Service for testing
class MockAuthenticationService: AuthenticationServiceProtocol {
    var loginResult: Result<Bool, AuthenticationError>!
    private(set) var loginCallCount = 0
    private(set) var lastUsedEmail: String?
    private(set) var lastUsedPassword: String?

    func login(withEmail email: String, password: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        loginCallCount += 1
        lastUsedEmail = email
        lastUsedPassword = password
        // Use a small delay to better simulate async behavior for tests
        DispatchQueue.main.async {
            completion(self.loginResult)
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

    func testLogin_WithEmptyEmail_SetsErrorMessage() {
        // Given
        viewModel.email = ""
        viewModel.password = "password"

        // When
        viewModel.login()

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email address.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }

    func testLogin_WithInvalidEmailFormat_SetsErrorMessage() {
        // Given
        viewModel.email = "invalid-email"
        viewModel.password = "password"

        // When
        viewModel.login()

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid email address.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }

    func testLogin_WithEmptyPassword_SetsErrorMessage() {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = ""

        // When
        viewModel.login()

        // Then
        XCTAssertEqual(viewModel.errorMessage, "Password cannot be empty.")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(mockAuthService.loginCallCount, 0)
    }

    func testLogin_WhenLoginStarts_IsLoadingIsTrueAndErrorIsNil() {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        viewModel.errorMessage = "Previous Error"
        mockAuthService.loginResult = .success(true)

        // When
        viewModel.login()

        // Then
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
    }

    func testLogin_OnSuccessfulLogin_IsAuthenticatedIsTrue() {
        // Given
        mockAuthService.loginResult = .success(true)
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        let expectation = XCTestExpectation(description: "Login completes and sets isAuthenticated")

        viewModel.$isAuthenticated
            .dropFirst() // Ignore initial value
            .sink { isAuthenticated in
                if isAuthenticated {
                    XCTAssertFalse(self.viewModel.isLoading)
                    XCTAssertNil(self.viewModel.errorMessage)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.login()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(mockAuthService.lastUsedEmail, "test@example.com")
        XCTAssertEqual(mockAuthService.lastUsedPassword, "password123")
    }

    func testLogin_OnFailedLogin_SetsErrorMessage() {
        // Given
        mockAuthService.loginResult = .failure(.invalidCredentials)
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrongpassword"
        
        let expectation = XCTestExpectation(description: "Login fails and sets error message")

        viewModel.$errorMessage
            .dropFirst()
            .sink { errorMessage in
                if errorMessage != nil {
                    XCTAssertEqual(errorMessage, AuthenticationError.invalidCredentials.localizedDescription)
                    XCTAssertFalse(self.viewModel.isLoading)
                    XCTAssertFalse(self.viewModel.isAuthenticated)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.login()

        // Then
        wait(for: [expectation], timeout: 1.0)
    }
}
