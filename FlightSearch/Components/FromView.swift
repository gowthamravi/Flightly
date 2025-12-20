import SwiftUI

struct FromView: View {
    var body: some View {
        VStack(spacing: 10) {
            Group {
                // Group 65 placeholder content
                HStack {
                    Text("From")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color.textPrimary)
                    Spacer()
                }
            }
            .frame(width: 97, height: 30)
        }
        .frame(width: 280, height: 52)
        .padding(EdgeInsets(top: 11, leading: 18, bottom: 11, trailing: 18))
        .background(Color.backgroundWhite)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.borderGray, lineWidth: 1)
        )
    }
}

#Preview {
    FromView()
        .padding()
        .background(Color.backgroundGray)
}