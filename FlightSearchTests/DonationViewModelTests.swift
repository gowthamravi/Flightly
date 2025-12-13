import XCTest
import Combine
@testable import FlightSearch // Assuming FlightSearch is the module name

class DonationViewModelTests: XCTestCase {

    var viewModel: DonationViewModel!
    var cancellables: Set<AnyCancellable>!
    var mockDonationService: MockDonationService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockDonationService = MockDonationService()
        viewModel = DonationViewModel(donationService: mockDonationService) // Inject mock service
        cancellables = Set<AnyCancellable>()
    }

    override func tearDownWithError() throws {
        viewModel = nil
        cancellables = nil
        mockDonationService = nil
        try super.tearDownWithError()
    }

    func testInitialState() {
        XCTAssertEqual(viewModel.donationAmountString, "")
        XCTAssertEqual(viewModel.selectedCurrency, .usd)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.successMessage)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.donateButtonDisabled) // Initially, amount is empty
        XCTAssertFalse(viewModel.isDonationSuccessful)
    }

    func testDonationAmountValidation_ValidAmount() {
        viewModel.donationAmountString = "100.50"
        XCTAssertFalse(viewModel.donateButtonDisabled)
        XCTAssertNil(viewModel.errorMessage)

        viewModel.donationAmountString = "1"
        XCTAssertFalse(viewModel.donateButtonDisabled)
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDonationAmountValidation_InvalidAmount_Empty() {
        viewModel.donationAmountString = ""
        XCTAssertTrue(viewModel.donateButtonDisabled)
        XCTAssertNil(viewModel.errorMessage) // No error message when empty, just disabled button
    }

    func testDonationAmountValidation_InvalidAmount_Zero() {
        viewModel.donationAmountString = "0"
        XCTAssertTrue(viewModel.donateButtonDisabled)
        XCTAssertEqual(viewModel.errorMessage, "Donation amount must be positive.")
    }

    func testDonationAmountValidation_InvalidAmount_Negative() {
        viewModel.donationAmountString = "-10"
        XCTAssertTrue(viewModel.donateButtonDisabled)
        XCTAssertEqual(viewModel.errorMessage, "Donation amount must be positive.")
    }

    func testDonationAmountValidation_InvalidAmount_NonNumeric() {
        viewModel.donationAmountString = "abc"
        XCTAssertTrue(viewModel.donateButtonDisabled)
        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid number.")

        viewModel.donationAmountString = "10.5.5" // Multiple decimal points
        XCTAssertTrue(viewModel.donateButtonDisabled)
        XCTAssertEqual(viewModel.errorMessage, "Please enter a valid number.")
    }

    func testCurrencySelection() {
        viewModel.selectedCurrency = .eur
        XCTAssertEqual(viewModel.selectedCurrency, .eur)
        XCTAssertNil(viewModel.errorMessage) // Changing currency clears messages
        XCTAssertNil(viewModel.successMessage)

        viewModel.selectedCurrency = .gbp
        XCTAssertEqual(viewModel.selectedCurrency, .gbp)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertNil(viewModel.successMessage)
    }

    func testSuccessfulDonation() {
        let expectation = XCTestExpectation(description: "Donation successful")
        mockDonationService.shouldSucceed = true
        mockDonationService.delay = 0.1 // Shorten delay for tests

        viewModel.donationAmountString = "50"
        
        // We expect `isLoading` to go false -> true -> false.
        var isLoadingSequence: [Bool] = []
        viewModel.$isLoading
            .sink { isLoading in
                isLoadingSequence.append(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$successMessage
            .dropFirst() // Drop initial nil
            .sink { message in
                if message != nil {
                    // Only fulfill when success message is actually set
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.processDonation()

        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(isLoadingSequence, [false, true, false])
        XCTAssertNotNil(self.viewModel.successMessage)
        XCTAssertEqual(self.viewModel.successMessage, "Thank you for your donation of 50.00 USD!")
        XCTAssertTrue(self.viewModel.isDonationSuccessful)
        XCTAssertFalse(self.viewModel.isLoading)
        XCTAssertEqual(self.viewModel.donationAmountString, "") // Should clear after success
        XCTAssertNil(self.viewModel.errorMessage) // No error on success
    }

    func testFailedDonation() {
        let expectation = XCTestExpectation(description: "Donation failed")
        mockDonationService.shouldSucceed = false
        mockDonationService.delay = 0.1 // Shorten delay for tests

        viewModel.donationAmountString = "25"
        viewModel.selectedCurrency = .eur
        
        var isLoadingSequence: [Bool] = []
        viewModel.$isLoading
            .sink { isLoading in
                isLoadingSequence.append(isLoading)
            }
            .store(in: &cancellables)
        
        viewModel.$errorMessage
            .dropFirst() // Drop initial nil
            .sink { message in
                if message != nil {
                    // Only fulfill when error message is actually set
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        viewModel.processDonation()

        wait(for: [expectation], timeout: 1.0)
        
        XCTAssertEqual(isLoadingSequence, [false, true, false])
        XCTAssertNotNil(self.viewModel.errorMessage)
        XCTAssertFalse(self.viewModel.isDonationSuccessful)
        XCTAssertFalse(self.viewModel.isLoading)
        XCTAssertEqual(self.viewModel.donationAmountString, "25") // Should not clear input on failure
        XCTAssertNil(self.viewModel.successMessage) // No success message on failure
        // The actual error description might vary slightly based on environment/Xcode version.
        XCTAssertTrue(self.viewModel.errorMessage?.contains("Donation failed") == true)
    }
    
    func testDonationInputClearsMessages() {
        // Simulate a successful donation first
        let successExp = expectation(description: "Successful donation completion")
        mockDonationService.shouldSucceed = true
        mockDonationService.delay = 0.1
        viewModel.donationAmountString = "10"
        
        viewModel.$successMessage
            .dropFirst() // Drop initial nil
            .sink { message in
                if message != nil {
                    successExp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        viewModel.processDonation()
        wait(for: [successExp], timeout: 1.0)

        XCTAssertNotNil(viewModel.successMessage)
        XCTAssertEqual(viewModel.donationAmountString, "") // Amount cleared after success

        // Now, set a new amount, which should clear the success message
        let clearExp = expectation(description: "Messages cleared on new input")
        viewModel.$successMessage
            .dropFirst(2) // Drop initial nil, then the success message itself
            .sink { message in
                if message == nil {
                    clearExp.fulfill()
                }
            }
            .store(in: &cancellables)
        
        // Set an error message first to ensure it also clears
        viewModel.errorMessage = "Some prior error"
        XCTAssertNotNil(viewModel.errorMessage)
        
        viewModel.donationAmountString = "50" // This should trigger clearing
        wait(for: [clearExp], timeout: 1.0)
        
        XCTAssertNil(viewModel.successMessage)
        XCTAssertNil(viewModel.errorMessage)
        XCTAssertFalse(viewModel.isDonationSuccessful)
    }
}