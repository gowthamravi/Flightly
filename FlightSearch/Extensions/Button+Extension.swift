import SwiftUI

extension Button {
    func flightlyButtonStyle() -> some View {
        self.buttonStyle(PlainButtonStyle())
            .background(Color(red: 227 / 255, green: 143 / 255, blue: 188 / 255))
            .cornerRadius(8)
    }
}