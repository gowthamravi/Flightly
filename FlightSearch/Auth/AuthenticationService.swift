import Foundation

// Custom error for authentication failures
enum AuthError: Error, LocalizedError {
    case invalidCredentials
    case networkError

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid username or password. Please try again."
        case .networkError:
            return "A network error occurred. Please check your connection."
        }
    }
}

// Protocol for dependency injection and testability
protocol AuthenticationServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void)
}

// Mock implementation of the authentication service
class AuthenticationService: AuthenticationServiceProtocol {
    func login(username: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        // Simulate a network delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            // Hardcoded credentials for demonstration purposes
            if username.lowercased() == "testuser" && password == "password123" {
                let user = User(id: UUID(), username: "testuser")
                completion(.success(user))
            } else {
                completion(.failure(AuthError.invalidCredentials))
            }
        }
    }
}
