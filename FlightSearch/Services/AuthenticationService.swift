import Foundation

enum AuthError: Error, CustomStringConvertible {
    case invalidCredentials
    case networkError

    var description: String {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .networkError:
            return "A network error occurred. Please check your connection."
        }
    }
}

protocol AuthenticationServiceProtocol {
    func login(email: String, password: String) async throws
}

class AuthenticationService: AuthenticationServiceProtocol {
    func login(email: String, password: String) async throws {
        // Simulate a network request
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Mock logic: succeed for a specific user, fail for others
        if email.lowercased() == "test@flightly.com" && password == "password123" {
            return
        } else {
            throw AuthError.invalidCredentials
        }
    }
}
