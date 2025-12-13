import SwiftUI

struct BorderedView: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .overlay( 
                RoundedRectangle(cornerRadius: 8) 
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
    }
}

extension View {
    func bordered() -> some View {
        self.modifier(BorderedView())
    }
}
