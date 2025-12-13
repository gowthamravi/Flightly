import Foundation
import AuthenticationServices

enum AuthError: Error, LocalizedError {
    case invalidEmailOrPassword
    case networkError(Error)
    case unknownError
    case appleSignInError(Error)
    case googleSignInError(Error)

    var errorDescription: String? {
        switch self {
        case .invalidEmailOrPassword: return "Incorrect email or password."
        case .networkError(let error): return "Network error: \(error.localizedDescription)"
        case .unknownError: return "An unexpected error occurred. Please try again."
        case .appleSignInError(let error): return "Apple Sign-In failed: \(error.localizedDescription)"
        case .googleSignInError(let error): return "Google Sign-In failed: \(error.localizedDescription)"
        }
    }
}

protocol AuthServiceProtocol {
    func login(email: String, password: String) async throws -> String
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> String
    func signInWithGoogle() async throws -> String // Placeholder for Google SDK integration
}

class AuthService: AuthServiceProtocol {
    private let keychainService: KeychainServiceProtocol

    init(keychainService: KeychainServiceProtocol = KeychainService()) {
        self.keychainService = keychainService
    }

    // Simulates an API call for email/password login
    func login(email: String, password: String) async throws -> String {
        // CRITICAL: Ensure password is NEVER logged in console.
        // print("Attempting login for email: \(email), password: \(password)") // DO NOT UNCOMMENT THIS IN PRODUCTION
        
        // Simulate network delay
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 seconds

        // Simulate API response: 401 for specific credentials, success otherwise
        if email == "test@example.com" && password == "password" {
            // Simulate 401 Unauthorized
            throw AuthError.invalidEmailOrPassword
        } else if email == "error@example.com" {
            // Simulate a generic network error
            throw AuthError.networkError(URLError(.notConnectedToInternet))
        } else {
            // Simulate successful login with a dummy token
            let authToken = "mockAuthToken_\(UUID().uuidString)"
            // Store token in Keychain
            if let tokenData = authToken.data(using: .utf8) {
                _ = keychainService.save(key: "authToken", data: tokenData)
            }
            return authToken
        }
    }

    // Simulates Apple Sign-In processing
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second

        // In a real app, you would send `credential.identityToken` and `credential.authorizationCode`
        // to your backend for verification and session creation.
        // For this simulation, we'll just return a success token.
        
        if let identityToken = credential.identityToken, let tokenString = String(data: identityToken, encoding: .utf8) {
            let authToken = "mockAppleAuthToken_\(UUID().uuidString)"
            if let tokenData = authToken.data(using: .utf8) {
                _ = keychainService.save(key: "authToken", data: tokenData)
            }
            return authToken
        } else {
            throw AuthError.appleSignInError(NSError(domain: "AuthService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to get identity token from Apple."]))
        }
    }

    // Placeholder for Google Sign-In SDK flow
    func signInWithGoogle() async throws -> String {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 1 * 1_000_000_000) // 1 second
        
        // In a real app, this would involve calling the Google Sign-In SDK and handling its callbacks.
        // For this simulation, we'll just return a success token.
        let authToken = "mockGoogleAuthToken_\(UUID().uuidString)"
        if let tokenData = authToken.data(using: .utf8) {
            _ = keychainService.save(key: "authToken", data: tokenData)
        }
        return authToken
    }
}
