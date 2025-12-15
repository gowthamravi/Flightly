import SwiftUI

struct FlightlyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(height: 44)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.brandPink)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

extension View {
    func flightlyButtonStyle() -> some View {
        self.buttonStyle(FlightlyButton())
    }
}
