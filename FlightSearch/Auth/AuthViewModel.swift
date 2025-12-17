import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var isAuthenticated = false

    private var cancellables = Set<AnyCancellable>()

    var isLoginButtonDisabled: Bool {
        email.isEmpty || password.isEmpty || !isValidEmail(email)
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    func login() {
        guard !isLoginButtonDisabled else { return }

        isLoading = true
        errorMessage = nil

        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            if self.email == "test@example.com" && self.password == "password123" {
                self.isAuthenticated = true
            } else {
                self.errorMessage = "Invalid email or password. Please try again."
            }
            self.isLoading = false
        }
    }
}
