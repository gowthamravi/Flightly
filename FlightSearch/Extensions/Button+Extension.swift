import SwiftUI

extension Button {
    /// Creates a button with a custom background color.
    /// - Parameters:
    ///   - background: The background color of the button.
    ///   - action: The action to perform when the button is tapped.
    ///   - label: The label of the button.
    /// - Returns: A `Button` with the specified background color.
    static func flightlyButton(background: Color, action: @escaping () -> Void, label: @escaping () -> Label) -> Button<Label> {
        Button(action: action) {
            label()
                .padding()
                .background(background)
                .foregroundColor(.white) // Assuming white text for contrast
                .cornerRadius(8) // Added for better visual appearance
        }
    }
    
    /// Creates a `FlightlyButton` with a predefined background color (227, 143, 188).
    /// - Parameters:
    ///   - action: The action to perform when the button is tapped.
    ///   - label: The label of the button.
    /// - Returns: A `Button` with the specified background color.
    static func flightlyButtonPrimary(action: @escaping () -> Void, label: @escaping () -> Label) -> Button<Label> {
        let purpleColor = Color(red: 227/255, green: 143/255, blue: 188/255)
        return Button.flightlyButton(background: purpleColor, action: action, label: label)
    }
}