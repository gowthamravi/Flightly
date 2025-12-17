import Foundation

// Custom error enum for authentication failures
enum AuthenticationError: Error, LocalizedError, Equatable {
    case invalidCredentials
    case networkError(String)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .networkError(let message):
            return "A network error occurred: \(message)"
        case .unknown:
            return "An unknown error occurred. Please try again later."
        }
    }
}

// Protocol for dependency injection and testability
protocol AuthenticationServiceProtocol {
    func login(email: String, password: String) async -> Result<User, AuthenticationError>
}

// A mock service that simulates a real authentication backend
class MockAuthenticationService: AuthenticationServiceProtocol {
    func login(email: String, password: String) async -> Result<User, AuthenticationError> {
        // Simulate network delay
        try? await Task.sleep(for: .seconds(1))

        // Mocked logic: accept a specific user/pass combination
        if email.lowercased() == "test@example.com" && password == "password123" {
            let user = User(id: UUID(), email: email, name: "Test User")
            return .success(user)
        } else {
            return .failure(.invalidCredentials)
        }
    }
}
