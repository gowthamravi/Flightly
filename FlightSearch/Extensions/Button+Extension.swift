import SwiftUI

/// A custom button style that applies the primary brand appearance.
struct FlightlyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.brandPrimary) // Updated to use the new brand color
            .foregroundColor(.white) // Ensures text remains white and legible
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extension
extension Button {
    /// Applies the `FlightlyButton` style to a button.
    func flightlyStyle() -> some View {
        self.buttonStyle(FlightlyButtonStyle())
    }
}
