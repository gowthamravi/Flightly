import XCTest
@testable import FlightSearch

final class LoginViewModelTests: XCTestCase {

    func testLoginSuccess() {
        let expectation = self.expectation(description: "Login should succeed")
        let mockService = MockAuthenticationService(result: .success(()))
        AuthenticationService.shared = mockService

        mockService.login(email: "test@example.com", password: "password123") { result in
            switch result {
            case .success:
                expectation.fulfill()
            case .failure:
                XCTFail("Login should not fail")
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }

    func testLoginFailure() {
        let expectation = self.expectation(description: "Login should fail")
        let mockService = MockAuthenticationService(result: .failure(NSError(domain: "Test", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"])))
        AuthenticationService.shared = mockService

        mockService.login(email: "test@example.com", password: "wrongpassword") { result in
            switch result {
            case .success:
                XCTFail("Login should not succeed")
            case .failure(let error):
                XCTAssertEqual(error.localizedDescription, "Invalid credentials")
                expectation.fulfill()
            }
        }

        waitForExpectations(timeout: 2.0, handler: nil)
    }
}

class MockAuthenticationService: AuthenticationService {
    private let result: Result<Void, Error>

    init(result: Result<Void, Error>) {
        self.result = result
    }

    override func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
        completion(result)
    }
}