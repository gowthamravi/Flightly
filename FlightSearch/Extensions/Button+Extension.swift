import SwiftUI

extension Color {
    /// The primary color for Flightly buttons and other UI elements.
    /// RGB: 227, 143, 188
    static let flightlyPrimary = Color(red: 227/255.0, green: 143/255.0, blue: 188/255.0)
    // MARK: - Add other custom colors here as needed
}

/**
 A custom button style for `FlightlyButton` providing a consistent look and feel.
 */
struct FlightlyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(
                Capsule()
                    .fill(Color.flightlyPrimary) // Updated to the new color
            )
            .foregroundColor(.white) // Text color remains white for contrast
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

extension ButtonStyle where Self == FlightlyButtonStyle {
    /// A convenience static property to apply `FlightlyButtonStyle`.
    static var flightly: FlightlyButtonStyle { .init() }
}

/**
 A reusable button component that automatically applies the `FlightlyButtonStyle`.
 */
struct FlightlyButton<Content: View>: View {
    let action: () -> Void
    let label: Content

    init(action: @escaping () -> Void, @ViewBuilder label: () -> Content) {
        self.action = action
        self.label = label()
    }

    var body: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.flightly)
    }
}

// MARK: - Preview Provider (for development purposes)
struct FlightlyButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            FlightlyButton(action: {}) {
                Text("Tap Me")
            }
            
            FlightlyButton(action: {}) {
                Label("Continue", systemImage: "arrow.right.circle.fill")
            }
            
            Button("Standard Button") { /* action */ }
                .buttonStyle(.borderedProminent)

        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
