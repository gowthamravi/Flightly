import Foundation
import Combine
import AuthenticationServices // Required for Apple Sign-In types like ASAuthorizationAppleIDCredential

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false // To drive navigation after successful login

    private var authService: AuthServiceProtocol
    private var keychainService: KeychainServiceProtocol // Using protocol for better testability

    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = AuthService(),
         keychainService: KeychainServiceProtocol = KeychainService()) {
        self.authService = authService
        self.keychainService = keychainService

        // Observe changes to email and password to update login button state
        // Button is disabled if email or password are empty, or if email format is invalid
        $email
            .combineLatest($password)
            .map { email, password in
                return email.isEmpty || password.isEmpty || !email.isValidEmail
            }
            .assign(to: \.isLoginButtonDisabled, on: self)
            .store(in: &cancellables)
    }

    @Published var isLoginButtonDisabled: Bool = true // Initial state

    func login() {
        guard !isLoginButtonDisabled else { return } // Prevent accidental taps if UI isn't fully disabled

        isLoading = true
        errorMessage = nil // Clear previous errors

        // Using Task for async operations in SwiftUI ViewModels
        Task {
            do {
                let token = try await authService.login(email: email, password: password)
                
                // Store token securely in Keychain
                if let tokenData = token.data(using: .utf8) {
                    keychainService.save(key: "authToken", data: tokenData)
                }
                
                // Update UI on the main thread
                DispatchQueue.main.async {
                    self.isAuthenticated = true // Signal successful authentication
                    self.password = "" // Clear password field for security
                    self.isLoading = false
                    print("Login successful. Token stored in Keychain.") // For debugging, not sensitive info
                }
            } catch let error as AuthServiceError {
                DispatchQueue.main.async {
                    self.isLoading = false
                    if case .unauthorized = error { // Specific handling for 401 error
                        self.errorMessage = "Incorrect email or password."
                    } else {
                        self.errorMessage = "Login failed: \(error.localizedDescription)"
                    }
                    self.password = "" // Clear password on failure for security
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "An unexpected error occurred: \(error.localizedDescription)"
                    self.password = "" // Clear password on unexpected error for security
                }
            }
        }
    }

    func handleAppleSignIn(authorization: ASAuthorization?, error: Error?) {
        isLoading = true
        errorMessage = nil

        if let error = error { // Handle errors from Apple Sign-In flow itself
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Apple Sign-In failed: \(error.localizedDescription)"
                print("Apple Sign-In client error: \(error.localizedDescription)")
            }
            return
        }

        guard let authorization = authorization,
              let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Apple Sign-In failed: Could not retrieve credential."
                print("Apple Sign-In error: Credential was not of expected type or missing.")
            }
            return
        }

        // Send the credential to your backend for verification and user creation/login
        Task {
            do {
                let token = try await authService.loginWithApple(credential: appleIDCredential)
                if let tokenData = token.data(using: .utf8) {
                    keychainService.save(key: "authToken", data: tokenData)
                }
                DispatchQueue.main.async {
                    self.isAuthenticated = true
                    self.isLoading = false
                    print("Apple Sign-In successful. Token stored in Keychain.")
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = "Apple Sign-In verification failed: \(error.localizedDescription)"
                    print("Apple Sign-In backend verification failed: \(error.localizedDescription)")
                }
            }
        }
    }

    func handleGoogleSignIn() {
        isLoading = true
        errorMessage = nil
        print("Google Sign-In tapped - initiating SDK flow (simulated)")

        // TODO: Integrate actual Google Sign-In SDK flow here.
        // This typically involves:
        // 1. Setting `GIDSignIn.sharedInstance.presentingViewController` to the root view controller.
        // 2. Calling `GIDSignIn.sharedInstance.signIn()`.
        // 3. Handling the result in a delegate or a completion block.
        
        // For demonstration, we simulate a successful login after a delay
        Task {
            do {
                let token = try await authService.loginWithGoogle()
                if let tokenData = token.data(using: .utf8) {
                    keychainService.save(key: "authToken", data: tokenData)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Simulate network delay
                    self.isAuthenticated = true
                    self.isLoading = false
                    print("Google Sign-In successful. Token stored in Keychain.")
                }
            } catch {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    self.isLoading = false
                    self.errorMessage = "Google Sign-In failed: \(error.localizedDescription)"
                    print("Google Sign-In failed: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // Optional: Helper to retrieve auth token (e.g., for checking session on app launch)
    func getAuthToken() -> String? {
        if let data = keychainService.retrieve(key: "authToken") {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }
    
    func logout() {
        let _ = keychainService.delete(key: "authToken")
        DispatchQueue.main.async {
            self.isAuthenticated = false
            self.email = ""
            self.password = ""
            print("Logged out. Token deleted from Keychain.")
        }
    }
}
