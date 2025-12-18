import SwiftUI

struct FlightlyButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.white)
            .padding()
            .background(Color(red: 227/255, green: 143/255, blue: 188/255))
            .cornerRadius(8)
    }
}

extension View {
    func flightlyButtonStyle() -> some View {
        self.modifier(FlightlyButton())
    }
}