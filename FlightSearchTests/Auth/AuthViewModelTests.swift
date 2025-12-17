import XCTest
import Combine
@testable import FlightSearch

class AuthViewModelTests: XCTestCase {

    var viewModel: AuthViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        viewModel = AuthViewModel()
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        cancellables = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.email, "")
        XCTAssertEqual(viewModel.password, "")
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
    }

    func testLoginButtonDisabledWithEmptyFields() {
        viewModel.email = ""
        viewModel.password = ""
        XCTAssertTrue(viewModel.isLoginButtonDisabled)

        viewModel.email = "test@example.com"
        viewModel.password = ""
        XCTAssertTrue(viewModel.isLoginButtonDisabled)

        viewModel.email = ""
        viewModel.password = "password"
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
    }
    
    func testLoginButtonDisabledWithInvalidEmail() {
        viewModel.email = "invalid-email"
        viewModel.password = "password123"
        XCTAssertTrue(viewModel.isLoginButtonDisabled)
    }

    func testLoginButtonEnabledWithValidFields() {
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        XCTAssertFalse(viewModel.isLoginButtonDisabled)
    }

    func testSuccessfulLogin() {
        let expectation = XCTestExpectation(description: "Successful login should set isAuthenticated to true")

        viewModel.email = "test@example.com"
        viewModel.password = "password123"

        viewModel.$isAuthenticated
            .dropFirst() // Ignore initial value of false
            .sink { isAuthenticated in
                if isAuthenticated {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login()

        XCTAssertTrue(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)

        wait(for: [expectation], timeout: 2.0)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.isAuthenticated)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testFailedLogin() {
        let expectation = XCTestExpectation(description: "Failed login should set an error message")

        viewModel.email = "wrong@example.com"
        viewModel.password = "wrongpassword"

        viewModel.$errorMessage
            .dropFirst() // Ignore initial nil value
            .sink { errorMessage in
                if errorMessage != nil {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.login()

        XCTAssertTrue(viewModel.isLoading)

        wait(for: [expectation], timeout: 2.0)

        XCTAssertFalse(viewModel.isLoading)
        XCTAssertFalse(viewModel.isAuthenticated)
        XCTAssertNotNil(viewModel.errorMessage)
        XCTAssertEqual(viewModel.errorMessage, "Invalid email or password. Please try again.")
    }
}
