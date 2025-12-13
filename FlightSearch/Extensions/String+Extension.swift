import Foundation

extension String {
    // MARK: - Email Validation
    
    /// A computed property to validate if the string conforms to a common email format.
    /// This provides client-side validation for UX but should always be backed by server-side validation.
    var isValidEmail: Bool {
        // A common and reasonably comprehensive regex for email validation.
        // It checks for: characters before @, @ symbol, characters between @ and ., and domain suffix.
        // While not 100% RFC-compliant (which is extremely complex), it covers most real-world emails.
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}