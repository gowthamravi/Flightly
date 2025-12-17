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
    
    var isLoginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || isLoading
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await authenticationService.login(email: email, password: password)
                self.isAuthenticated = true
            } catch {
                if let authError = error as? AuthError {
                    self.errorMessage = authError.localizedDescription
                } else {
                    self.errorMessage = "An unexpected error occurred."
                }
                self.isAuthenticated = false
            }
            self.isLoading = false
        }
    }
}
