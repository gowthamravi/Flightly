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

struct CustomBoarderStyle: ViewModifier {
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
    func flightlyButtonStyle() -> some View {
        self.modifier(FlightlyButton())
    }
    
    func customBoarderStyle() -> some View {
        self.modifier(CustomBoarderStyle())
    }
}

extension Button {
    func flightlyStyle() -> some View {
        self.modifier(FlightlyButton())
    }
    
    func buttonStyle<S: ButtonStyle>(_ style: S) -> some View {
        self.buttonStyle(style)
    }
}