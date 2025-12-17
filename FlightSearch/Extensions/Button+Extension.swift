import SwiftUI

struct FlightlyButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(BrandColor.flightlyPink)
            .clipShape(Capsule())
    }
}

extension View {
    func flightlyButton() -> some View {
        self.modifier(FlightlyButton())
    }
}
