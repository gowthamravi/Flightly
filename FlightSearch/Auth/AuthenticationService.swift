import Foundation

// Define a protocol for testability and dependency injection
protocol AuthenticationServiceProtocol {
    func login(email: String, password: String) async throws
}

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

// Concrete implementation of the authentication service
class AuthenticationService: AuthenticationServiceProtocol {
    func login(email: String, password: String) async throws {
        // Simulate a network request delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 second delay
        
        // Simple validation logic for demonstration purposes
        if email.lowercased() == "test@example.com" && password == "password" {
            // In a real application, you would handle session tokens, user data, etc.
            return
        } else {
            throw AuthError.invalidCredentials
        }
    }
}
