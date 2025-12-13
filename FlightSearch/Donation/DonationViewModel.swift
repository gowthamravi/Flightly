import Foundation
import Combine

enum Currency: String, CaseIterable, Identifiable {
    case usd = "USD"
    case eur = "EUR"
    case gbp = "GBP"

    var id: String { self.rawValue }
}

class DonationViewModel: ObservableObject {
    @Published var donationAmountString: String = "" {
        didSet {
            // Filter non-numeric characters, allow only one decimal point
            var filtered = donationAmountString.filter { "0123456789.".contains($0) }
            
            // Ensure only one decimal point
            if let firstDotIndex = filtered.firstIndex(of: ".") {
                let prefix = filtered[...firstDotIndex]
                let suffix = filtered[filtered.index(after: firstDotIndex)...].filter { $0 != "." }
                filtered = String(prefix) + String(suffix)
            }
            
            if filtered != donationAmountString {
                donationAmountString = filtered
            }
            validateInput()
        }
    }
    @Published var selectedCurrency: Currency = .usd
    @Published var errorMessage: String? = nil
    @Published var successMessage: String? = nil
    @Published var isLoading: Bool = false
    @Published var isDonationSuccessful: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private let donationService: DonationServiceProtocol

    var donateButtonDisabled: Bool {
        return isLoading || !isValidAmount()
    }

    // Initializer for SwiftUI preview and production, allowing service injection for testing
    init(donationService: DonationServiceProtocol = MockDonationService()) {
        self.donationService = donationService
        setupBindings()
    }

    private func setupBindings() {
        // Reset messages when input or currency changes
        $donationAmountString
            .sink { [weak self] _ in
                self?.errorMessage = nil
                self?.successMessage = nil
                self?.isDonationSuccessful = false
            }
            .store(in: &cancellables)

        $selectedCurrency
            .sink { [weak self] _ in
                self?.errorMessage = nil
                self?.successMessage = nil
                self?.isDonationSuccessful = false
            }
            .store(in: &cancellables)
    }

    private func isValidAmount() -> Bool {
        guard !donationAmountString.isEmpty, let amount = Double(donationAmountString) else {
            return false
        }
        return amount > 0
    }

    private func validateInput() {
        guard !donationAmountString.isEmpty else {
            errorMessage = nil // Clear error if empty, button will be disabled by isValidAmount()
            return
        }

        if Double(donationAmountString) == nil {
            errorMessage = "Please enter a valid number."
        } else if Double(donationAmountString)! <= 0 {
            errorMessage = "Donation amount must be positive."
        } else {
            errorMessage = nil
        }
    }

    func processDonation() {
        errorMessage = nil
        successMessage = nil
        isDonationSuccessful = false

        guard isValidAmount(), let amount = Double(donationAmountString) else {
            errorMessage = "Please enter a valid positive donation amount."
            return
        }

        isLoading = true

        donationService.makeDonation(amount: amount, currency: selectedCurrency)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false
                switch completion {
                case .failure(let error):
                    self.errorMessage = "Donation failed: \(error.localizedDescription)"
                case .finished:
                    break
                }
            } receiveValue: { [weak self] _ in
                guard let self = self else { return }
                self.successMessage = "Thank you for your donation of \(String(format: "%.2f", amount)) \(self.selectedCurrency.rawValue)!"
                self.isDonationSuccessful = true
                self.donationAmountString = "" // Clear input after successful donation
            }
            .store(in: &cancellables)
    }
}