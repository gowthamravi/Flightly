import Foundation
import Combine

enum DonationError: Error, LocalizedError {
    case networkError(String)
    case invalidResponse
    case generalError

    var errorDescription: String? {
        switch self {
        case .networkError(let message): return "Network Error: \(message)"
        case .invalidResponse: return "Invalid server response."
        case .generalError: return "An unexpected error occurred."
        }
    }
}

protocol DonationServiceProtocol {
    func makeDonation(amount: Double, currency: Currency) -> AnyPublisher<Void, DonationError>
}

// MARK: - Mock Service for Development and Testing

class MockDonationService: DonationServiceProtocol {
    var shouldSucceed: Bool = true
    var delay: TimeInterval = 0.5 // Default delay

    func makeDonation(amount: Double, currency: Currency) -> AnyPublisher<Void, DonationError> {
        return Future<Void, DonationError> { promise in
            DispatchQueue.main.asyncAfter(deadline: .now() + self.delay) {
                if self.shouldSucceed {
                    promise(.success(()))
                } else {
                    promise(.failure(.generalError))
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

// MARK: - API Service (Conceptual, for a real backend integration)

/*
class APIDonationService: DonationServiceProtocol {
    private let networkClient: NetworkClientProtocol // Assume a network client is available

    init(networkClient: NetworkClientProtocol) {
        self.networkClient = networkClient
    }

    func makeDonation(amount: Double, currency: Currency) -> AnyPublisher<Void, DonationError> {
        let requestBody: [String: Any] = [
            "amount": amount,
            "currency": currency.rawValue
        ]

        return networkClient.post(path: "/donations", body: requestBody)
            .tryMap { data, response in
                guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                    throw DonationError.invalidResponse
                }
                return ()
            }
            .mapError { error in
                if let donationError = error as? DonationError {
                    return donationError
                }
                return .networkError(error.localizedDescription)
            }
            .eraseToAnyPublisher()
    }
}
*/