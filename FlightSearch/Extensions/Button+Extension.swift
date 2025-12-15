import SwiftUI

// Note: Per DP-12, only the background color was changed.
// The struct name and other modifiers remain untouched to minimize regression risk.
struct FlightlyButton: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline)
            .foregroundColor(.white)
            .frame(height: 55)
            .frame(maxWidth: .infinity)
            .background(BrandColor.flightlyPink) // Updated color from DP-12
            .clipShape(Capsule())
    }
}

extension View {
    func flightlyButtonStyle() -> some View {
        self.modifier(FlightlyButton())
    }
}
