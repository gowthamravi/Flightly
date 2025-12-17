import XCTest
import Combine
@testable import FlightSearch

// Mock Authentication Service for testing
class MockAuthenticationService: AuthenticationServiceProtocol {
    var loginResult: Result<User, Error>!

    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        completion(loginResult)
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
        viewModel = LoginViewModel(authService: mockAuthService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.username, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled initially")
    }

    func testLoginButtonEnabledState() {
        // Initially disabled
        XCTAssertTrue(viewModel.isLoginButtonDisabled)

        // Enabled when both fields have text
        viewModel.username = "test"
        viewModel.password = "pass"
        XCTAssertFalse(viewModel.isLoginButtonDisabled, "Login button should be enabled when credentials are provided")

        // Disabled when loading
        viewModel.isLoading = true
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Login button should be disabled while loading")
    }

    func testSuccessfulLogin() {
        // Given
        let user = User(id: UUID(), username: "testuser")
        mockAuthService.loginResult = .success(user)
        viewModel.username = "testuser"
        viewModel.password = "password123"

        let expectation = XCTestExpectation(description: "State updates on successful login")
        
        viewModel.$isAuthenticated
            .dropFirst() // Ignore initial value
            .sink { isAuthenticated in
                if isAuthenticated {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        viewModel.login()

        // Then
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(self.viewModel.isLoading)
        XCTAssertTrue(self.viewModel.isAuthenticated)
        XCTAssertNil(self.viewModel.errorMessage)
    }

    func testFailedLogin() {
        // Given
        let error = AuthError.invalidCredentials
        mockAuthService.loginResult = .failure(error)
        viewModel.username = "wronguser"
        viewModel.password = "wrongpass"

        let expectation = XCTestExpectation(description: "State updates on failed login")

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
        XCTAssertTrue(viewModel.isLoading)

        wait(for: [expectation], timeout: 1.0)

        XCTAssertFalse(self.viewModel.isLoading)
        XCTAssertFalse(self.viewModel.isAuthenticated)
        XCTAssertEqual(self.viewModel.errorMessage, error.errorDescription)
    }
}
