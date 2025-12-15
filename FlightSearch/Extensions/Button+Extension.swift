import SwiftUI

struct FlightlyButton: ButtonStyle {
    static let backgroundColor = Color(red: 227/255, green: 143/255, blue: 188/255)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Self.backgroundColor)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

extension View {
    func flightlyButtonStyle() -> some View {
        self.buttonStyle(FlightlyButton())
    }
}
