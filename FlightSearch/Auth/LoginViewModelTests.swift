import XCTest
@testable import FlightSearch

final class LoginViewModelTests: XCTestCase {

    func testLoginWithEmptyFields() {
        let viewModel = LoginViewModel()
        viewModel.email = ""
        viewModel.password = ""

        viewModel.login()

        XCTAssertEqual(viewModel.errorMessage, "Please fill in all fields.")
    }

    func testLoginWithInvalidCredentials() {
        let viewModel = LoginViewModel()
        viewModel.email = "invalid@example.com"
        viewModel.password = "wrongpassword"

        let expectation = self.expectation(description: "Login should fail")

        viewModel.login { success in
            XCTAssertFalse(success)
            XCTAssertEqual(viewModel.errorMessage, "Invalid email or password.")
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testLoginWithValidCredentials() {
        let viewModel = LoginViewModel()
        viewModel.email = "valid@example.com"
        viewModel.password = "correctpassword"

        let expectation = self.expectation(description: "Login should succeed")

        viewModel.login { success in
            XCTAssertTrue(success)
            XCTAssertNil(viewModel.errorMessage)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }
}