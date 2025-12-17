import XCTest
import Combine
@testable import FlightSearch

// Mock service specifically for testing different scenarios
class ControllableMockAuthService: AuthenticationServiceProtocol {
    var loginResult: Result<User, AuthenticationError>!
    private(set) var loginCallCount = 0

    func login(email: String, password: String) async -> Result<User, AuthenticationError> {
        loginCallCount += 1
        // Allow the test to control the result
        return loginResult
    }
}

@MainActor
final class LoginViewModelTests: XCTestCase {

    private var viewModel: LoginViewModel!
    private var mockAuthService: ControllableMockAuthService!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockAuthService = ControllableMockAuthService()
        viewModel = LoginViewModel(authService: mockAuthService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }

    func testLogin_Success() async {
        // Given
        let user = User(id: UUID(), email: "test@example.com", name: "Test User")
        mockAuthService.loginResult = .success(user)
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        let expectation = XCTestExpectation(description: "isAuthenticated becomes true")
        viewModel.$isAuthenticated
            .dropFirst()
            .sink { XCTAssertTrue($0); expectation.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.login()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
    }

    func testLogin_Failure_InvalidCredentials() async {
        // Given
        let error = AuthenticationError.invalidCredentials
        mockAuthService.loginResult = .failure(error)
        viewModel.email = "wrong@example.com"
        viewModel.password = "wrongpass"

        let expectation = XCTestExpectation(description: "errorMessage is set correctly")
        viewModel.$errorMessage
            .dropFirst()
            .sink { XCTAssertEqual($0, error.localizedDescription); expectation.fulfill() }
            .store(in: &cancellables)

        // When
        viewModel.login()

        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
    }

    func testIsLoginButtonDisabled_InitialState() {
        // Then
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Button should be disabled when fields are empty")
    }

    func testIsLoginButtonDisabled_WhenLoading() {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.isLoading = true

        // Then
        XCTAssertTrue(viewModel.isLoginButtonDisabled, "Button should be disabled while loading")
    }

    func testIsLoginButtonDisabled_FieldsPopulated() {
        // Given
        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        // Then
        XCTAssertFalse(viewModel.isLoginButtonDisabled, "Button should be enabled when fields are populated and not loading")
    }
    
    func testLogin_DoesNotTrigger_WhenButtonIsDisabled() {
        // Given
        viewModel.email = ""
        viewModel.password = ""
        
        // When
        viewModel.login()
        
        // Then
        XCTAssertEqual(mockAuthService.loginCallCount, 0, "Login service should not be called if form is invalid")
    }
    
    func testLoadingState_TogglesDuringLogin() async {
        // Given
        mockAuthService.loginResult = .success(User(id: UUID(), email: "", name: ""))
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        var loadingStates: [Bool] = []
        let expectation = XCTestExpectation(description: "isLoading toggles from false -> true -> false")
        
        viewModel.$isLoading.sink { isLoading in
            loadingStates.append(isLoading)
            if loadingStates.count == 3 { // Initial false, true during call, false after completion
                expectation.fulfill()
            }
        }.store(in: &cancellables)
        
        // When
        viewModel.login()
        
        // Then
        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(loadingStates, [false, true, false])
    }
}
