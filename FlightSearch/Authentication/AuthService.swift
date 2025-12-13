import Foundation
import AuthenticationServices // For ASAuthorizationAppleIDCredential in social login methods

// Protocol for the authentication service to allow for mocking in tests
protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> String
    func loginWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> String
    func loginWithGoogle() async throws -> String
}

enum AuthServiceError: Error, LocalizedError {
    case invalidCredentials
    case unauthorized // Specific error for HTTP 401 response
    case networkError(Error)
    case serverError(statusCode: Int)
    case decodingError(Error)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password provided."
        case .unauthorized:
            return "Incorrect email or password." // User-friendly message for 401
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .serverError(let statusCode):
            return "Server error with status code: \(statusCode)"
        case .decodingError(let error):
            return "Data decoding error: \(error.localizedDescription)"
        case .unknown:
            return "An unknown error occurred. Please try again."
        }
    }
}

class AuthService: AuthServiceProtocol {
    // In a real application, this would use URLSession to make actual API calls.
    // For this task, we will simulate network responses and errors.

    func login(email: String, password: String) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // Simulate API responses based on input
        if email == "user@example.com" && password == "password123" {
            return "mock_auth_token_123" // Simulate successful login
        } else if email == "unauthorized@example.com" && password == "wrong" {
            throw AuthServiceError.unauthorized // Simulate 401 Unauthorized
        } else if email == "servererror@example.com" {
            throw AuthServiceError.serverError(statusCode: 500) // Simulate a 500 Internal Server Error
        } else {
            throw AuthServiceError.invalidCredentials // Simulate other login failures
        }
    }

    func loginWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> String {
        // Simulate network delay for backend call
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // In a real application, you would send the `credential.identityToken`
        // and `credential.authorizationCode` to your backend for verification.
        // The backend would then authenticate the user and return an app-specific token.
        
        // For demonstration, print relevant parts and simulate success.
        print("\n--- Apple Sign-In Credential Received ---")
        print("User ID: \(credential.user)")
        print("Given Name: \(credential.fullName?.givenName ?? "N/A")")
        print("Email: \(credential.email ?? "N/A")")
        // NEVER LOG identityToken or authorizationCode directly in production, only send to backend.
        // print("Identity Token (base64): \(credential.identityToken?.base64EncodedString() ?? "N/A")")
        // print("Authorization Code (base64): \(credential.authorizationCode?.base64EncodedString() ?? "N/A")")
        print("------------------------------------------\n")

        // Simulate a token from your backend
        return "mock_apple_auth_token_456"
    }

    func loginWithGoogle() async throws -> String {
        // Simulate network delay for backend call
        try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds

        // In a real application, after the Google Sign-In SDK completes, you would obtain
        // an ID token or access token and send it to your backend for verification.
        // The backend would then authenticate the user and return an app-specific token.
        print("Simulating Google Sign-In backend call and token exchange.")

        // Simulate a token from your backend
        return "mock_google_auth_token_789"
    }
}
