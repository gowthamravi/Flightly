import XCTest
@testable import FlightSearch

class LoginViewTests: XCTestCase {

    func testLoginView_InitialState() throws {
        let loginView = LoginView()
        XCTAssertEqual(loginView.username, "")
        XCTAssertEqual(loginView.password, "")
        XCTAssertFalse(loginView.isPasswordVisible)
    }

    func testLoginView_UsernameAndPasswordInput() throws {
        let loginView = LoginView()
        loginView.username = "testUser"
        loginView.password = "testPassword"
        XCTAssertEqual(loginView.username, "testUser")
        XCTAssertEqual(loginView.password, "testPassword")
    }

    func testLoginView_PasswordVisibilityToggle() throws {
        var loginView = LoginView()
        loginView.isPasswordVisible = false
        loginView.isPasswordVisible.toggle()
        XCTAssertTrue(loginView.isPasswordVisible)
        loginView.isPasswordVisible.toggle()
        XCTAssertFalse(loginView.isPasswordVisible)
    }

    func testLoginView_ValidLogin() throws {
        var loginView = LoginView()
        loginView.username = "user"
        loginView.password = "password"
        XCTAssertTrue(loginView.isValidLogin())
    }

    func testLoginView_InvalidLogin() throws {
        var loginView = LoginView()
        loginView.username = "wrongUser"
        loginView.password = "wrongPassword"
        XCTAssertFalse(loginView.isValidLogin())
    }

    func testLoginView_EmptyUsernameLogin() throws {
        var loginView = LoginView()
        loginView.username = ""
        loginView.password = "password"
        XCTAssertFalse(loginView.isValidLogin())
    }

    func testLoginView_EmptyPasswordLogin() throws {
        var loginView = LoginView()
        loginView.username = "user"
        loginView.password = ""
        XCTAssertFalse(loginView.isValidLogin())
    }

    func testLoginView_EmptyUsernameAndPasswordLogin() throws {
        var loginView = LoginView()
        loginView.username = ""
        loginView.password = ""
        XCTAssertFalse(loginView.isValidLogin())
    }
}
