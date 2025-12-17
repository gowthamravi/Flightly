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
        guard validateInputs() else { return }

        isLoading = true
        errorMessage = nil

        authenticationService.login(withEmail: email, password: password) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success:
                self.isAuthenticated = true
            case .failure(let error):
                self.errorMessage = error.localizedDescription
                self.isAuthenticated = false
            }
        }
    }

    private func validateInputs() -> Bool {
        if email.isEmpty || !email.contains("@") {
            errorMessage = "Please enter a valid email address."
            return false
        }
        if password.isEmpty {
            errorMessage = "Password cannot be empty."
            return false
        }
        errorMessage = nil
        return true
    }
}
