import SwiftUI

extension Button {
    // Define a custom color for FlightlyButton
    static let flightlyColor = Color(red: 227.0/255.0, green: 143.0/255.0, blue: 188.0/255.0)
    
    // You might have a specific button style or modifier for "FlightlyButton"
    // If so, update its definition here. For example:
    
    func flightlyButtonStyle() -> some View {
        self.buttonStyle(FlightlyButtonStyle())
    }
}

// If FlightlyButtonStyle is a custom struct, you would define it elsewhere.
// Example placeholder:
struct FlightlyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(Button.flightlyColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// If you have a direct way to apply this color to any button, you could add a modifier
extension View {
    func flightlyButtonColor() -> some View {
        self.background(Button.flightlyColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
