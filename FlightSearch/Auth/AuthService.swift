import Foundation

enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError
    
    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .networkError:
            return "A network error occurred. Please check your connection."
        }
    }
}

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User
}

class AuthService: AuthServiceProtocol {
    func login(email: String, password: String) async throws -> User {
        // Simulate network delay
        try await Task.sleep(for: .seconds(2))

        // Mock implementation: check for specific credentials
        if email.lowercased() == "test@example.com" && password == "password123" {
            return User(id: UUID(), email: email, name: "Test User")
        } else {
            throw AuthError.invalidCredentials
        }
    }
}
