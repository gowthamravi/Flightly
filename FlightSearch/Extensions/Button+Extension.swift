import SwiftUI

extension Button {
    func flightlyButtonStyle() -> some View {
        self.buttonStyle(PlainButtonStyle())
            .padding()
            .background(Color(red: 227/255, green: 143/255, blue: 188/255))
            .foregroundColor(.white)
            .cornerRadius(8)
    }
}