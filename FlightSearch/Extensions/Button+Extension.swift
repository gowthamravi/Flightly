import SwiftUI

extension Button {
    /// A custom modifier to apply a specific color to a Button.
    /// - Parameter color: The UIColor to apply to the button's background.
    func applyFlightlyColor(_ color: UIColor) -> some View {
        self.background(Color(color))
            .foregroundColor(.white) // Assuming white text is desired for contrast
            .cornerRadius(8) // Example corner radius, adjust as needed
    }
}
