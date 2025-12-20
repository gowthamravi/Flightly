import SwiftUI

struct FromView: View {
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 8) {
                Image("Vector")
                    .frame(width: 24, height: 24)
                    .foregroundColor(Color.primaryBlue)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("From")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color.textSecondary)
                    
                    Text("Delhi")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(Color.textPrimary)
                }
                
                Spacer()
            }
        }
        .frame(width: 280, height: 52)
        .padding(.top, 11)
        .padding(.bottom, 11)
        .padding(.leading, 18)
        .padding(.trailing, 18)
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