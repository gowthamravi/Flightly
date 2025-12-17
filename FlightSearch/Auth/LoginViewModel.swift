import Foundation
import Combine

@MainActor
class LoginViewModel: ObservableObject {
    
    @Published var username = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private let authService: AuthenticationServiceProtocol

    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }

    var isLoginButtonDisabled: Bool {
        username.isEmpty || password.isEmpty || isLoading
    }

    func login() {
        isLoading = true
        errorMessage = nil

        authService.login(username: username, password: password) { [weak self] result in
            guard let self = self else { return }
            
            self.isLoading = false
            switch result {
            case .success(let user):
                print("Successfully logged in user: \(user.username)")
                self.isAuthenticated = true
            case .failure(let error):
                self.errorMessage = (error as? LocalizedError)?.errorDescription ?? "An unknown error occurred."
                self.isAuthenticated = false
            }
        }
    }
}
