import SwiftUI

struct FlightlyButton: ButtonStyle {
    // The background color is now a testable property.
    let backgroundColor = Color(red: 227/255, green: 143/255, blue: 188/255)

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(backgroundColor)
            .clipShape(Capsule())
    }
}
