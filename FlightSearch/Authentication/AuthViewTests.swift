import XCTest
import Combine
@testable import FlightSearch // Replace with your actual target name if different
import AuthenticationServices

// MARK: - MockKeychainService
class MockKeychainService: KeychainServiceProtocol {
    var storedData: [String: Data] = [:]
    var saveStatus: OSStatus = errSecSuccess
    var retrieveData: Data? = nil
    var deleteStatus: OSStatus = errSecSuccess

    func save(key: String, data: Data) -> OSStatus {
        storedData[key] = data
        return saveStatus
    }
    
    func retrieve(key: String) -> Data? {
        return storedData[key] ?? retrieveData
    }
    
    func delete(key: String) -> OSStatus {
        storedData[key] = nil
        return deleteStatus
    }
}

// MARK: - MockAuthService
class MockAuthService: AuthServiceProtocol {
    var loginResult: Result<String, AuthError> = .success("mockToken")
    var appleSignInResult: Result<String, AuthError> = .success("mockAppleToken")
    var googleSignInResult: Result<String, AuthError> = .success("mockGoogleToken")
    
    var loginCallCount = 0
    var appleSignInCallCount = 0
    var googleSignInCallCount = 0

    func login(email: String, password: String) async throws -> String {
        loginCallCount += 1
        try await Task.sleep(nanoseconds: 10_000_000) // Small delay to simulate async
        switch loginResult {
        case .success(let token): return token
        case .failure(let error): throw error
        }
    }

    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> String {
        appleSignInCallCount += 1
        try await Task.sleep(nanoseconds: 10_000_000)
        switch appleSignInResult {
        case .success(let token): return token
        case .failure(let error): throw error
        }
    }

    func signInWithGoogle() async throws -> String {
        googleSignInCallCount += 1
        try await Task.sleep(nanoseconds: 10_000_000)
        switch googleSignInResult {
        case .success(let token): return token
        case .failure(let error): throw error
        }
    }
}

// MARK: - AuthViewModelTests
final class AuthViewModelTests: XCTestCase {
    var viewModel: AuthViewModel!
    var mockAuthService: MockAuthService!
    var mockKeychainService: MockKeychainService!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        mockKeychainService = MockKeychainService()
        mockAuthService = MockAuthService()
        // Inject the mock service into the real view model
        viewModel = AuthViewModel(authService: mockAuthService)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        mockAuthService = nil
        mockKeychainService = nil
        cancellables = nil
        super.tearDown()
    }

    @MainActor
    func testInitialState() {
        XCTAssertTrue(viewModel.email.isEmpty)
        XCTAssertTrue(viewModel.password.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
    }

    @MainActor
    func testEmailValidation() {
        viewModel.email = "invalid-email"
        XCTAssertEqual(viewModel.emailValidationMessage, "Invalid email format")
        viewModel.email = "valid@example.com"
        XCTAssertNil(viewModel.emailValidationMessage)
        viewModel.email = ""
        XCTAssertNil(viewModel.emailValidationMessage)
    }

    @MainActor
    func testLoginButtonDisabledState() {
        // Empty fields
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertTrue(viewModel.isLoginButtonDisabled)

        // Only email
        viewModel.email = "test@example.com"
        XCTAssertTrue(viewModel.isLoginButtonDisabled)

        // Only password
        viewModel.email = ""
        viewModel.password = "password"
        XCTAssertTrue(viewModel.isLoginButtonDisabled)

        // Valid but invalid email format
        viewModel.email = "invalid"
        viewModel.password = "password"
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
        
        // Valid fields
        viewModel.email = "test@example.com"
        viewModel.password = "password"
        XCTAssertFalse(viewModel.isLoginButtonDisabled)
        
        // Loading state should disable button
        viewModel.isLoading = true
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
        viewModel.isLoading = false
        XCTAssertFalse(viewModel.isLoginButtonDisabled)
    }

    @MainActor
    func testLoginSuccess() async throws {
        let expectation = XCTestExpectation(description: "Login success")
        
        viewModel.$showLoginSuccessAlert
            .dropFirst()
            .sink { success in
                if success { expectation.fulfill() }
            }
            .store(in: &cancellables)

        viewModel.email = "user@example.com"
        viewModel.password = "correctpassword"
        mockAuthService.loginResult = .success("mockAuthToken123")
        
        await viewModel.loginWithEmailPassword()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        // Verify that the view model triggered the alert for success
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.showLoginSuccessAlert)
    }

    @MainActor
    func testLoginFailure_IncorrectCredentials() async {
        let expectation = XCTestExpectation(description: "Login failure")
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { message in
                if message != nil { expectation.fulfill() }
            }
            .store(in: &cancellables)

        viewModel.email = "test@example.com"
        viewModel.password = "password"
        mockAuthService.loginResult = .failure(.invalidEmailOrPassword)

        await viewModel.loginWithEmailPassword()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, AuthError.invalidEmailOrPassword.errorDescription)
        XCTAssertEqual(mockAuthService.loginCallCount, 1)
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testLoginFailure_NetworkError() async {
        let expectation = XCTestExpectation(description: "Login network error")
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { message in
                if message != nil { expectation.fulfill() }
            }
            .store(in: &cancellables)

        viewModel.email = "network@example.com"
        viewModel.password = "password"
        mockAuthService.loginResult = .failure(.networkError(URLError(.cannotConnectToHost)))

        await viewModel.loginWithEmailPassword()

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, AuthError.networkError(URLError(.cannotConnectToHost)).errorDescription)
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testAppleSignInSuccess() async throws {
        let expectation = XCTestExpectation(description: "Apple Sign-In success")
        
        viewModel.$showLoginSuccessAlert
            .dropFirst()
            .sink { success in
                if success { expectation.fulfill() }
            }
            .store(in: &cancellables)

        mockAuthService.appleSignInResult = .success("mockAppleAuthToken")
        
        let mockCredential = ASAuthorizationAppleIDCredential()
        
        // A dummy identity token is often required for actual credential objects
        // Since we cannot initialize ASAuthorizationAppleIDCredential directly with mock data easily,
        // we are relying on the mockAuthService to just return success.
        // For a full test, one might mock the credential creation or use a helper.
        
        await viewModel.signInWithApple(credential: mockCredential)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAuthService.appleSignInCallCount, 1)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.showLoginSuccessAlert)
    }
    
    @MainActor
    func testAppleSignInFailure() async throws {
        let expectation = XCTestExpectation(description: "Apple Sign-In failure")
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { message in
                if message != nil { expectation.fulfill() }
            }
            .store(in: &cancellables)
        
        mockAuthService.appleSignInResult = .failure(.appleSignInError(NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Apple Error"]))) 
        let mockCredential = ASAuthorizationAppleIDCredential() // Dummy
        
        await viewModel.signInWithApple(credential: mockCredential)
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Apple Sign-In failed: Apple Error")
        XCTAssertEqual(mockAuthService.appleSignInCallCount, 1)
        wait(for: [expectation], timeout: 1.0)
    }

    @MainActor
    func testGoogleSignInSuccess() async throws {
        let expectation = XCTestExpectation(description: "Google Sign-In success")
        
        viewModel.$showLoginSuccessAlert
            .dropFirst()
            .sink { success in
                if success { expectation.fulfill() }
            }
            .store(in: &cancellables)

        mockAuthService.googleSignInResult = .success("mockGoogleAuthToken")
        
        await viewModel.signInWithGoogle()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertEqual(mockAuthService.googleSignInCallCount, 1)
        wait(for: [expectation], timeout: 1.0)
        XCTAssertTrue(viewModel.showLoginSuccessAlert)
    }
    
    @MainActor
    func testGoogleSignInFailure() async throws {
        let expectation = XCTestExpectation(description: "Google Sign-In failure")
        
        viewModel.$errorMessage
            .dropFirst()
            .sink { message in
                if message != nil { expectation.fulfill() }
            }
            .store(in: &cancellables)
        
        mockAuthService.googleSignInResult = .failure(.googleSignInError(NSError(domain: "Test", code: 2, userInfo: [NSLocalizedDescriptionKey: "Google Error"]))) 
        
        await viewModel.signInWithGoogle()
        
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertEqual(viewModel.errorMessage, "Google Sign-In failed: Google Error")
        XCTAssertEqual(mockAuthService.googleSignInCallCount, 1)
        wait(for: [expectation], timeout: 1.0)
    }
    
    @MainActor
    func testForgotPasswordCall() {
        viewModel.forgotPassword()
        // For a simple print, there's no state change to assert, but in a real app,
        // one might assert navigation or a specific event being triggered.
        // XCTAssertTrue(true, "forgotPassword method was called") // Placeholder assertion
    }
}
