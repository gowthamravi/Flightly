import Foundation
import Combine
import AuthenticationServices

class AuthViewModel: NSObject, ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    @Published var showLoginSuccessAlert: Bool = false
    
    // Email Validation
    var emailValidationMessage: String? {
        guard !email.isEmpty else { return nil }
        let emailPattern = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailPattern)
        return emailPredicate.evaluate(with: email) ? nil : "Invalid email format"
    }
    
    // Login Button State
    var isLoginButtonDisabled: Bool {
        return email.isEmpty || password.isEmpty || emailValidationMessage != nil || isLoading
    }
    
    private let authService: AuthServiceProtocol
    
    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }
    
    @MainActor
    func loginWithEmailPassword() async {
        guard !isLoginButtonDisabled else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.login(email: email, password: password)
            showLoginSuccessAlert = true
            // Optionally navigate away or reset fields on success
            email = ""
            password = ""
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.unknownError.errorDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func signInWithApple(credential: ASAuthorizationAppleIDCredential) async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.signInWithApple(credential: credential)
            showLoginSuccessAlert = true
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.unknownError.errorDescription
        }
        
        isLoading = false
    }
    
    @MainActor
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            _ = try await authService.signInWithGoogle()
            showLoginSuccessAlert = true
        } catch let error as AuthError {
            errorMessage = error.errorDescription
        } catch {
            errorMessage = AuthError.unknownError.errorDescription
        }
        
        isLoading = false
    }
    
    func forgotPassword() {
        // In a real app, navigate to a "Forgot Password" flow
        print("Forgot Password tapped")
    }
}

// MARK: - ASAuthorizationControllerDelegate & ASAuthorizationControllerPresentationContextProviding
extension AuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            Task { @MainActor in
                await signInWithApple(credential: appleIDCredential)
            }
        default:
            break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // Handle error.
        // For example, if the user cancels the sign-in flow, this delegate method will be called.
        if let authError = error as? ASAuthorizationError {
            if authError.code == .canceled {
                // User cancelled, clear loading state without showing an error message necessarily
                print("Apple Sign-In cancelled.")
            } else {
                errorMessage = AuthError.appleSignInError(authError).errorDescription
            }
        } else {
            errorMessage = AuthError.appleSignInError(error).errorDescription
        }
        isLoading = false
    }
}

// NOTE: ASAuthorizationControllerPresentationContextProviding needs to be implemented by a UIViewController or a wrapper around it.
// For SwiftUI, we often use a `UIViewControllerRepresentable` or pass the window scene to the controller.
// For simplicity in this `AuthViewModel`, we'll assume the `AuthView` handles the presentation context.
