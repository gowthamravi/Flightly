import Foundation

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoggingIn = false
    @Published var errorMessage: String?
    @Published var loginSuccessful = false

    private let authService: AuthenticationServiceProtocol

    var isLoginDisabled: Bool {
        email.isEmpty || password.isEmpty || isLoggingIn
    }

    init(authService: AuthenticationServiceProtocol = AuthenticationService()) {
        self.authService = authService
    }

    func login() async {
        errorMessage = nil
        isLoggingIn = true

        do {
            try await authService.login(email: email, password: password)
            loginSuccessful = true
        } catch let error as AuthError {
            errorMessage = error.description
        } catch {
            errorMessage = "An unexpected error occurred."
        }
        
        isLoggingIn = false
    }
}
