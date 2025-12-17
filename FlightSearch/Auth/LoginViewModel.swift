import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let authService: AuthServiceProtocol

    var isLoginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func login() {
        guard !isLoginButtonDisabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let _ = try await authService.login(email: email, password: password)
                // On success, update state to trigger navigation or view change
                self.isAuthenticated = true
            } catch {
                if let authError = error as? AuthError {
                    self.errorMessage = authError.localizedDescription
                } else {
                    self.errorMessage = "An unexpected error occurred."
                }
            }
            self.isLoading = false
        }
    }
}
