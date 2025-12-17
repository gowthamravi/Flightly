import Foundation

// A simple error enum for authentication failures.
enum AuthError: Error, Equatable {
    case invalidCredentials
    case networkError
    case unknown
}

// A simple User model.
struct User: Equatable {
    let id: UUID
    let email: String
    let name: String
}

// Protocol for testability and dependency injection.
protocol AuthenticationServiceProtocol {
    func login(email: String, password: String) async -> Result<User, AuthError>
}

// The concrete implementation of the authentication service.
// In a real app, this would make network requests to a backend.
class AuthenticationService: AuthenticationServiceProtocol {
    func login(email: String, password: String) async -> Result<User, AuthError> {
        // Simulate network delay of 1 second
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        // Simulate a successful login for specific credentials
        if email.lowercased() == "test@example.com" && password == "password123" {
            let user = User(id: UUID(), email: email.lowercased(), name: "Test User")
            return .success(user)
        } else {
            // Simulate a failed login for any other credentials
            return .failure(.invalidCredentials)
        }
    }
}
