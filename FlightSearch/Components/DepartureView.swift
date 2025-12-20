import SwiftUI

struct DepartureView: View {
    var body: some View {
        VStack(spacing: 10) {
            // Group 64 placeholder - content not specified in requirements
            Rectangle()
                .fill(Color.clear)
                .frame(width: 92, height: 30)
        }
        .frame(width: 133, height: 54)
        .padding(.top, 12)
        .padding(.bottom, 12)
        .padding(.leading, 18)
        .padding(.trailing, 170)
        .background(Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color(red: 239/255, green: 239/255, blue: 239/255), lineWidth: 1)
        )
    }
}

#Preview {
    DepartureView()
}