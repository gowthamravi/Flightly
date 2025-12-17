import Foundation

enum AuthenticationError: Error, LocalizedError {
    case invalidCredentials
    case custom(Error)

    var errorDescription: String? {
        switch self {
        case .invalidCredentials:
            return "Invalid email or password. Please try again."
        case .custom(let error):
            return error.localizedDescription
        }
    }
}

protocol AuthenticationServiceProtocol {
    func login(withEmail email: String, password: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void)
}

class AuthenticationService: AuthenticationServiceProtocol {
    func login(withEmail email: String, password: String, completion: @escaping (Result<Bool, AuthenticationError>) -> Void) {
        // Simulate a network request
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            if email.lowercased() == "test@example.com" && password == "password123" {
                completion(.success(true))
            } else {
                completion(.failure(.invalidCredentials))
            }
        }
    }
}
