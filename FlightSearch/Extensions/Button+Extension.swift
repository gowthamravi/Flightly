import SwiftUI

struct FlightlyButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(red: 227/255, green: 143/255, blue: 188/255))
                .cornerRadius(10)
        }
    }
}

struct FlightlyButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 227/255, green: 143/255, blue: 188/255))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

extension Button {
    func flightlyStyle() -> some View {
        self.buttonStyle(FlightlyButtonStyle())
    }
}

extension Color {
    static let flightlyPrimary = Color(red: 227/255, green: 143/255, blue: 188/255)
}