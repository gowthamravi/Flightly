import XCTest
import Combine
import AuthenticationServices // For ASAuthorizationAppleIDCredential
@testable import FlightSearch // Replace with your module name

// Mock AuthService for testing AuthViewModel
class MockAuthService: AuthServiceProtocol {
    var loginResult: Result<AuthToken, Error>?
    var appleSignInResult: Result<AuthToken, Error>?
    var googleSignInResult: Result<AuthToken, Error>?
    var authTokenFromKeychain: AuthToken? // Simulate keychain content
    var deleteKeychainCalled: Bool = false
    
    func login(email: String, password: String) async throws -> AuthToken {
        guard let result = loginResult else {
            fatalError("loginResult not set for MockAuthService")
        }
        switch result {
        case .success(let token): return token
        case .failure(let error): throw error
        }
    }
    
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> AuthToken {
        guard let result = appleSignInResult else {
            fatalError("appleSignInResult not set for MockAuthService")
        }
        switch result {
        case .success(let token): return token
        case .failure(let error): throw error
        }
    }
    
    func signInWithGoogle(idToken: String) async throws -> AuthToken {
        guard let result = googleSignInResult else {
            fatalError("googleSignInResult not set for MockAuthService")
        }
        switch result {
        case .success(let token): return token
        case .failure(let error): throw error
        }
    }
    
    func getAuthTokenFromKeychain() -> AuthToken? {
        return authTokenFromKeychain
    }
    
    func deleteAuthTokenFromKeychain() {
        deleteKeychainCalled = true
        authTokenFromKeychain = nil
    }
}

final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockAuthService: MockAuthService!
    var cancellables: Set<AnyCancellable>!
    
    override func setUp() {
        super.setUp()
        mockAuthService = MockAuthService()
        viewModel = AuthViewModel(authService: mockAuthService)
        cancellables = []
    }
    
    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        cancellables = nil
        super.tearDown()
    }
    
    // MARK: - Email Validation Tests
    
    func testEmailValidation_ValidEmail() {
        viewModel.email = "test@example.com"
        XCTAssertNil(viewModel.emailError)
        XCTAssertTrue(viewModel.isLoginButtonEnabled)
    }
    
    func testEmailValidation_InvalidEmail() {
        viewModel.email = "invalid-email"
        XCTAssertEqual(viewModel.emailError, "Invalid email format")
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
        
        viewModel.email = "invalid@"
        XCTAssertEqual(viewModel.emailError, "Invalid email format")
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
    
    func testEmailValidation_EmptyEmail() {
        viewModel.email = ""
        XCTAssertNil(viewModel.emailError)
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
    
    // MARK: - Login Button State Tests
    
    func testLoginButton_DisabledWhenFieldsEmpty() {
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
    
    func testLoginButton_DisabledWhenEmailInvalid() {
        viewModel.email = "invalid"
        viewModel.password = "password"
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
    
    func testLoginButton_DisabledWhenPasswordEmpty() {
        viewModel.email = "test@example.com"
        viewModel.password = ""
        XCTAssertFalse(viewModel.isLoginButtonEnabled)
    }
    
    func testLoginButton_EnabledWhenFieldsValid() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        // Give a moment for Combine publisher to update
        let expectation = XCTestExpectation(description: "isLoginButtonEnabled updates")
        viewModel.$isLoginButtonEnabled
            .dropFirst()
            .sink { isEnabled in
                if isEnabled { expectation.fulfill() }
            }
            .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 0.1)
        XCTAssertTrue(viewModel.isLoginButtonEnabled)
    }
    
    // MARK: - Login Action Tests
    
    func testLogin_Success() async throws {
        let expectedToken = AuthToken(accessToken: "mock_token")
        mockAuthService.loginResult = .success(expectedToken)
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let isAuthenticatedExpectation = XCTestExpectation(description: "isAuthenticated becomes true")
        viewModel.$isAuthenticated
            .dropFirst()
            .sink { isAuthenticated in
                if isAuthenticated { isAuthenticatedExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        await viewModel.login()
        
        wait(for: [isLoadingExpectation, isAuthenticatedExpectation], timeout: 3.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.showingAlert)
        XCTAssertEqual(viewModel.alertMessage, "")
    }
    
    func testLogin_Failure_Unauthorized() async throws {
        mockAuthService.loginResult = .failure(AuthError.invalidCredentials)
        
        viewModel.email = "error@example.com"
        viewModel.password = "wrongpassword"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let showingAlertExpectation = XCTestExpectation(description: "showingAlert becomes true")
        viewModel.$showingAlert
            .dropFirst()
            .sink { showingAlert in
                if showingAlert { showingAlertExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        await viewModel.login()
        
        wait(for: [isLoadingExpectation, showingAlertExpectation], timeout: 3.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.showingAlert)
        XCTAssertEqual(viewModel.alertMessage, "Incorrect email or password.")
    }
    
    func testLogin_Failure_NetworkError() async throws {
        mockAuthService.loginResult = .failure(AuthError.networkError(URLError(.notConnectedToInternet)))
        
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let showingAlertExpectation = XCTestExpectation(description: "showingAlert becomes true")
        viewModel.$showingAlert
            .dropFirst()
            .sink { showingAlert in
                if showingAlert { showingAlertExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        await viewModel.login()
        
        wait(for: [isLoadingExpectation, showingAlertExpectation], timeout: 3.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.showingAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("Network error"))
    }
    
    // MARK: - Apple Sign-In Tests
    
    func testAppleSignIn_Success() async throws {
        let expectedToken = AuthToken(accessToken: "apple_mock_token")
        mockAuthService.appleSignInResult = .success(expectedToken)
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let isAuthenticatedExpectation = XCTestExpectation(description: "isAuthenticated becomes true")
        viewModel.$isAuthenticated
            .dropFirst()
            .sink { isAuthenticated in
                if isAuthenticated { isAuthenticatedExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        // Mock ASAuthorizationAppleIDCredential (identityToken is optional here)
        let mockCredential = ASAuthorizationAppleIDCredential(identityToken: "someToken".data(using: .utf8), authorizationCode: nil, user: "user123", realUserStatus: .unknown, email: nil, fullName: nil)
        let mockAuthorization = ASAuthorization(credential: mockCredential)
        
        viewModel.handleAppleSignInResult(result: .success(mockAuthorization))
        
        wait(for: [isLoadingExpectation, isAuthenticatedExpectation], timeout: 2.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.showingAlert)
    }
    
    func testAppleSignIn_Failure() async throws {
        let mockError = NSError(domain: "AuthError", code: 100, userInfo: [NSLocalizedDescriptionKey: "User cancelled Apple Sign-In"])
        mockAuthService.appleSignInResult = .failure(mockError)
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let showingAlertExpectation = XCTestExpectation(description: "showingAlert becomes true")
        viewModel.$showingAlert
            .dropFirst()
            .sink { showingAlert in
                if showingAlert { showingAlertExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        viewModel.handleAppleSignInResult(result: .failure(mockError))
        
        wait(for: [isLoadingExpectation, showingAlertExpectation], timeout: 2.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.showingAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("User cancelled Apple Sign-In"))
    }
    
    // MARK: - Google Sign-In Tests (Simulated)
    
    func testGoogleSignIn_Success() async throws {
        let expectedToken = AuthToken(accessToken: "google_mock_token")
        mockAuthService.googleSignInResult = .success(expectedToken)
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let isAuthenticatedExpectation = XCTestExpectation(description: "isAuthenticated becomes true")
        viewModel.$isAuthenticated
            .dropFirst()
            .sink { isAuthenticated in
                if isAuthenticated { isAuthenticatedExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        await viewModel.signInWithGoogle() // This simulates the random success path in the ViewModel
        
        wait(for: [isLoadingExpectation, isAuthenticatedExpectation], timeout: 2.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertFalse(viewModel.showingAlert)
    }
    
    func testGoogleSignIn_Failure() async throws {
        mockAuthService.googleSignInResult = .failure(AuthError.googleSignInFailed(nil))
        
        let isLoadingExpectation = XCTestExpectation(description: "isLoading becomes true then false")
        isLoadingExpectation.expectedFulfillmentCount = 2
        viewModel.$isLoading
            .dropFirst()
            .sink { isLoading in
                isLoadingExpectation.fulfill()
            }
            .store(in: &cancellables)
        
        let showingAlertExpectation = XCTestExpectation(description: "showingAlert becomes true")
        viewModel.$showingAlert
            .dropFirst()
            .sink { showingAlert in
                if showingAlert { showingAlertExpectation.fulfill() }
            }
            .store(in: &cancellables)
        
        // To force failure, we need to ensure the random condition fails or directly call
        // the service with a failure. For the current ViewModel simulation, this test
        // might not reliably hit the failure path if Bool.random() is true. Adjusting mock
        // to control the outcome directly.
        
        // Re-initialize view model to ensure mock is fresh and directly inject error
        mockAuthService = MockAuthService()
        mockAuthService.googleSignInResult = .failure(AuthError.googleSignInFailed(nil))
        viewModel = AuthViewModel(authService: mockAuthService)
        viewModel.isAuthenticated = false // Reset state for test
        viewModel.isLoading = false
        viewModel.showingAlert = false
        
        await viewModel.signInWithGoogle()
        
        wait(for: [isLoadingExpectation, showingAlertExpectation], timeout: 2.0)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.showingAlert)
        XCTAssertTrue(viewModel.alertMessage.contains("Google Sign-In failed"))
    }
    
    // MARK: - Initial State and Keychain Tests
    
    func testInitialState_NotAuthenticated() {
        XCTAssertFalse(viewModel.isAuthenticated)
    }
    
    func testInitialState_AuthenticatedFromKeychain() {
        mockAuthService.authTokenFromKeychain = AuthToken(accessToken: "existing_token")
        viewModel = AuthViewModel(authService: mockAuthService) // Re-initialize to pick up keychain token
        
        XCTAssertTrue(viewModel.isAuthenticated)
    }
    
    func testLogout() {
        mockAuthService.authTokenFromKeychain = AuthToken(accessToken: "existing_token")
        viewModel = AuthViewModel(authService: mockAuthService)
        
        XCTAssertTrue(viewModel.isAuthenticated)
        
        viewModel.logout()
        
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(mockAuthService.deleteKeychainCalled)
    }
    
    func testResetAlert() {
        viewModel.alertMessage = "Some Error"
        viewModel.showingAlert = true
        
        viewModel.resetAlert()
        
        XCTAssertFalse(viewModel.showingAlert)
        XCTAssertEqual(viewModel.alertMessage, "")
    }
}
