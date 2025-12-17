import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    // MARK: - Private Properties
    private let authService: AuthenticationServiceProtocol

    // MARK: - Computed Properties
    var isLoginButtonDisabled: Bool {
        // Basic validation
        return email.isEmpty || password.isEmpty || isLoading
    }

    // MARK: - Initializer
    init(authService: AuthenticationServiceProtocol) {
        self.authService = authService
    }

    // MARK: - Public Methods
    func login() {
        guard !isLoginButtonDisabled else { return }

        isLoading = true
        errorMessage = nil

        Task {
            let result = await authService.login(email: email, password: password)
            handleLoginResult(result)
        }
    }

    // MARK: - Private Helper Methods
    private func handleLoginResult(_ result: Result<User, AuthenticationError>) {
        isLoading = false
        switch result {
        case .success:
            isAuthenticated = true
        case .failure(let error):
            errorMessage = error.localizedDescription
        }
    }
}
