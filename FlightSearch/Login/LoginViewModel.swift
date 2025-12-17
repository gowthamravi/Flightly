import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let authenticationService: AuthenticationServiceProtocol

    init(authenticationService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authenticationService = authenticationService
    }

    func login() {
        errorMessage = nil
        
        guard validateInputs() else { return }

        isLoading = true

        Task {
            let result = await authenticationService.login(email: email, password: password)
            
            handleLoginResult(result)
        }
    }
    
    private func handleLoginResult(_ result: Result<User, AuthError>) {
        isLoading = false
        switch result {
        case .success(let user):
            // In a real app, you would store the user session here.
            print("Successfully logged in user: \(user.name)")
            isAuthenticated = true
        case .failure(let error):
            handleAuthError(error)
        }
    }

    private func validateInputs() -> Bool {
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            return false
        }

        guard isValidEmail(email) else {
            errorMessage = "Please enter a valid email address."
            return false
        }
        return true
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    private func handleAuthError(_ error: AuthError) {
        switch error {
        case .invalidCredentials:
            errorMessage = "Invalid email or password. Please try again."
        case .networkError:
            errorMessage = "A network error occurred. Please check your connection."
        case .unknown:
            errorMessage = "An unknown error occurred. Please try again later."
        }
    }
}
