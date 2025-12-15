import SwiftUI

// MARK: - Theme Colors
extension Color {
    static let flightlyPink = Color(red: 227/255, green: 143/255, blue: 188/255)
}

// MARK: - Button Style

/// A primary button style used across the app, referred to as `FlightlyButton`.
struct FlightlyButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(Color.flightlyPink) // Updated color per DP-12
            .foregroundColor(.white)
            .clipShape(Capsule())
    }
}
