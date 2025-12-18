import SwiftUI

struct BorderedViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .foregroundColor(.primary)
            .padding()
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary, lineWidth: 1)
            )
    }
}

extension View {
    func borderedViewStyle() -> some View {
        self.modifier(BorderedViewModifier())
    }
}