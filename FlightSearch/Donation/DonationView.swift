import SwiftUI

struct DonationView: View {
    @StateObject var viewModel: DonationViewModel
    
    // Initializer to allow injecting ViewModel for Previews/testing
    init(viewModel: DonationViewModel = DonationViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Donation Details") {
                    HStack {
                        Text("Amount")
                        Spacer()
                        TextField("0.00", text: $viewModel.donationAmountString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .foregroundColor(viewModel.errorMessage != nil ? .red : .primary) // Visually indicate error
                    }
                    
                    Picker("Currency", selection: $viewModel.selectedCurrency) {
                        ForEach(Currency.allCases) { currency in
                            Text(currency.rawValue).tag(currency)
                        }
                    }
                }

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                if let successMessage = viewModel.successMessage {
                    Text(successMessage)
                        .foregroundColor(.green)
                        .font(.caption)
                }

                Section {
                    Button {
                        viewModel.processDonation()
                    } label: {
                        HStack {
                            Spacer()
                            if viewModel.isLoading {
                                ProgressView() // Standard SwiftUI loading indicator
                            } else {
                                Text("Donate")
                            }
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(viewModel.donateButtonDisabled)
                }
            }
            .navigationTitle("Make a Donation")
        }
    }
}

struct DonationView_Previews: PreviewProvider {
    static var previews: some View {
        // Example with a successful mock service
        DonationView(viewModel: DonationViewModel(donationService: MockDonationService(shouldSucceed: true)))
        
        // Example with a failing mock service
        // DonationView(viewModel: DonationViewModel(donationService: MockDonationService(shouldSucceed: false)))
    }
}